(function() {
  var MarketHelper, math, _;

  MarketHelper = require("../lib/market_helper");

  _ = require("underscore");

  math = require("mathjs")({
    number: "bignumber",
    decimals: 8
  });

  module.exports = function(sequelize, DataTypes) {
    var Order;
    Order = sequelize.define("Order", {
      user_id: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false
      },
      type: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        comment: "market, limit",
        get: function() {
          return MarketHelper.getOrderTypeLiteral(this.getDataValue("type"));
        },
        set: function(type) {
          return this.setDataValue("type", MarketHelper.getOrderType(type));
        }
      },
      action: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        comment: "buy, sell",
        get: function() {
          return MarketHelper.getOrderActionLiteral(this.getDataValue("action"));
        },
        set: function(action) {
          return this.setDataValue("action", MarketHelper.getOrderAction(action));
        }
      },
      buy_currency: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        get: function() {
          return MarketHelper.getCurrencyLiteral(this.getDataValue("buy_currency"));
        },
        set: function(buyCurrency) {
          return this.setDataValue("buy_currency", MarketHelper.getCurrency(buyCurrency));
        }
      },
      sell_currency: {
        type: DataTypes.INTEGER.UNSIGNED,
        allowNull: false,
        get: function() {
          return MarketHelper.getCurrencyLiteral(this.getDataValue("sell_currency"));
        },
        set: function(sellCurrency) {
          return this.setDataValue("sell_currency", MarketHelper.getCurrency(sellCurrency));
        }
      },
      amount: {
        type: DataTypes.BIGINT.UNSIGNED,
        defaultValue: 0,
        allowNull: false,
        validate: {
          isInt: true,
          notNull: true
        },
        comment: "FLOAT x 100000000"
      },
      matched_amount: {
        type: DataTypes.BIGINT.UNSIGNED,
        defaultValue: 0,
        validate: {
          isInt: true
        },
        comment: "FLOAT x 100000000"
      },
      result_amount: {
        type: DataTypes.BIGINT.UNSIGNED,
        defaultValue: 0,
        validate: {
          isInt: true
        },
        comment: "FLOAT x 100000000"
      },
      fee: {
        type: DataTypes.BIGINT.UNSIGNED,
        defaultValue: 0,
        validate: {
          isInt: true
        },
        comment: "FLOAT x 100000000"
      },
      unit_price: {
        type: DataTypes.BIGINT.UNSIGNED,
        defaultValue: 0,
        validate: {
          isInt: true
        },
        comment: "FLOAT x 100000000"
      },
      status: {
        type: DataTypes.INTEGER.UNSIGNED,
        defaultValue: MarketHelper.getOrderStatus("open"),
        allowNull: false,
        comment: "open, partiallyCompleted, completed",
        get: function() {
          return MarketHelper.getOrderStatusLiteral(this.getDataValue("status"));
        },
        set: function(status) {
          return this.setDataValue("status", MarketHelper.getOrderStatus(status));
        }
      },
      published: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
        allowNull: false
      },
      close_time: {
        type: DataTypes.DATE
      }
    }, {
      tableName: "orders",
      getterMethods: {
        inversed_action: function() {
          if (this.action === "sell") {
            return "buy";
          }
          if (this.action === "buy") {
            return "sell";
          }
        },
        left_amount: function() {
          return math.add(this.amount, -this.matched_amount);
        },
        left_hold_balance: function() {
          if (this.action === "buy") {
            return math.multiply(this.left_amount, MarketHelper.fromBigint(this.unit_price));
          }
          if (this.action === "sell") {
            return this.left_amount;
          }
        }
      },
      classMethods: {
        findById: function(id, callback) {
          return Order.find(id).complete(callback);
        },
        findByUserAndId: function(id, userId, callback) {
          return Order.find({
            where: {
              id: id,
              user_id: userId
            }
          }).complete(callback);
        },
        findByOptions: function(options, callback) {
          var currencies, query;
          if (options == null) {
            options = {};
          }
          query = {
            where: {},
            order: [["created_at", "DESC"]]
          };
          if (options.status === "open") {
            query.where.status = [MarketHelper.getOrderStatus("partiallyCompleted"), MarketHelper.getOrderStatus("open")];
          }
          if (options.status === "completed") {
            query.where.status = MarketHelper.getOrderStatus(options.status);
          }
          if (!!MarketHelper.getOrderAction(options.action)) {
            query.where.action = MarketHelper.getOrderAction(options.action);
          }
          if (options.user_id) {
            query.where.user_id = options.user_id;
          }
          if (options.action === "buy") {
            query.where.buy_currency = MarketHelper.getCurrency(options.currency1);
            query.where.sell_currency = MarketHelper.getCurrency(options.currency2);
          } else if (options.action === "sell") {
            query.where.buy_currency = MarketHelper.getCurrency(options.currency2);
            query.where.sell_currency = MarketHelper.getCurrency(options.currency1);
          } else if (!options.action) {
            currencies = [];
            if (options.currency1) {
              currencies.push(MarketHelper.getCurrency(options.currency1));
            }
            if (options.currency2) {
              currencies.push(MarketHelper.getCurrency(options.currency2));
            }
            if (currencies.length > 1) {
              query.where.buy_currency = currencies;
              query.where.sell_currency = currencies;
            } else if (currencies.length === 1) {
              query.where = sequelize.and(query.where, sequelize.or({
                buy_currency: currencies[0]
              }, {
                sell_currency: currencies[0]
              }));
            }
          } else {
            return callback("Wrong action", []);
          }
          if (options.published != null) {
            query.where.published = !!options.published;
          }
          if (options.sort_by) {
            query.order = options.sort_by;
          }
          return Order.findAll(query).complete(callback);
        },
        findCompletedByTimeAndAction: function(startTime, endTime, action, callback) {
          var query;
          query = {
            where: {
              status: MarketHelper.getOrderStatus("completed"),
              action: MarketHelper.getOrderAction(action),
              close_time: {
                gte: new Date(startTime),
                lte: new Date(endTime)
              }
            },
            order: [["close_time", "ASC"]]
          };
          return Order.findAll(query).complete(callback);
        },
        isValidTradeAmount: function(amount) {
          return _.isNumber(amount) && !_.isNaN(amount) && _.isFinite(amount) && amount >= MarketHelper.getMinTradeAmount();
        },
        isValidFee: function(amount, action, unitPrice) {
          if (MarketHelper.getTradeFee() === 0) {
            return true;
          }
          if (!_.isNumber(amount) || _.isNaN(amount) || !_.isFinite(amount)) {
            return false;
          }
          return MarketHelper.calculateFee(MarketHelper.calculateResultAmount(amount, action, unitPrice)) >= MarketHelper.getMinFeeAmount();
        },
        isValidSpendAmount: function(amount, action, unitPrice) {
          if (!_.isNumber(amount) || _.isNaN(amount) || !_.isFinite(amount)) {
            return false;
          }
          return MarketHelper.calculateSpendAmount(amount, action, unitPrice) >= MarketHelper.getMinSpendAmount();
        },
        isValidReceiveAmount: function(amount, action, unitPrice) {
          if (!_.isNumber(amount) || _.isNaN(amount) || !_.isFinite(amount)) {
            return false;
          }
          return MarketHelper.calculateResultAmount(amount, action, unitPrice) >= MarketHelper.getMinReceiveAmount();
        }
      },
      instanceMethods: {
        getFloat: function(attribute) {
          if (this[attribute] == null) {
            return this[attribute];
          }
          return MarketHelper.fromBigint(this[attribute]);
        },
        publish: function(callback) {
          if (callback == null) {
            callback = function() {};
          }
          return GLOBAL.walletsClient.send("publish_order", [this.id], (function(_this) {
            return function(err, res, body) {
              if (err) {
                console.error(err);
                return callback(err, res, body);
              }
              if (body && body.published) {
                return Order.findById(_this.id, callback);
              } else {
                console.error("Could not publish the order - " + (JSON.stringify(body)));
                return callback("Could not publish the order to the network");
              }
            };
          })(this));
        },
        cancel: function(callback) {
          if (callback == null) {
            callback = function() {};
          }
          return GLOBAL.walletsClient.send("cancel_order", [this.id], (function(_this) {
            return function(err, res, body) {
              if (err) {
                console.error(err);
                return callback(err, res, body);
              }
              if (body && body.canceled) {
                return callback();
              } else {
                console.error("Could not cancel the order - " + (JSON.stringify(body)));
                return callback("Could not cancel the order on the network");
              }
            };
          })(this));
        }
      }
    });
    return Order;
  };

}).call(this);
