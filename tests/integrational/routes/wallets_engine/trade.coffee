require "./../../../helpers/spec_helper"
marketStats = require './../../../../models/seeds/market_stats'

app = require "./../../../../wallets"
request = require "supertest"

describe "Trade Api", ->
  wallet = undefined

  beforeEach (done)->
    GLOBAL.db.sequelize.sync({force: true}).complete ()->
      GLOBAL.db.sequelize.query("TRUNCATE TABLE #{GLOBAL.db.MarketStats.tableName}").complete ()->
        GLOBAL.db.MarketStats.bulkCreate(marketStats).complete ()->
          done()

  describe "POST /orders_match", ()->
    describe "When a valid match order is coming in", ()->
      beforeEach (done)->
        wallets = [
          {id: 1, user_id: 1, currency: "BTC", balance: 9, hold_balance: 1}
          {id: 2, user_id: 1, currency: "LTC", balance: 0}
          {id: 3, user_id: 2, currency: "BTC", balance: 0}
          {id: 4, user_id: 2, currency: "LTC", balance: 5, hold_balance: 5}
        ]
        orders = [
          {id: 1, user_id: 1, type: "limit", action: "buy", buy_currency: "LTC", sell_currency: "BTC", amount: 10, unit_price: 0.1, status: "open", published: true}
          {id: 2, user_id: 2, type: "limit", action: "sell", buy_currency: "BTC", sell_currency: "LTC", amount: 5, unit_price: 0.1, status: "open", published: true}
        ]
        GLOBAL.db.Wallet.bulkCreate(wallets).complete ()->
          GLOBAL.db.Order.bulkCreate(orders).complete ()->
            done()

      matchData =
        [
          {id: 1, order_id: 1, matched_amount: 500000000, result_amount: 499000000, fee: 1000000, unit_price: 10000000, status: 'partiallyCompleted'}
          {id: 2, order_id: 2, matched_amount: 500000000, result_amount: 49900000, fee: 100000, unit_price: 10000000, status: 'completed'}
        ]
      
      it "returns 200 ok", (done)->
        request('http://localhost:6000')
        .post("/orders_match")
        .send(matchData)
        .expect(200)
        .end done

      it "sets the matched order data", (done)->
        request('http://localhost:6000')
        .post("/orders_match")
        .send(matchData)
        .expect(200)
        .end ()->
          GLOBAL.db.Order.find(1).complete (err, order)->
            order.amount.should.eql 10
            order.matched_amount.should.eql 5
            order.result_amount.should.eql 4.99
            order.fee.should.eql 0.01
            order.unit_price.should.eql 0.1
            order.status.should.eql "partiallyCompleted"
            done()

      it "sets the matching order data", (done)->
        request('http://localhost:6000')
        .post("/orders_match")
        .send(matchData)
        .expect(200)
        .end ()->
          GLOBAL.db.Order.find(2).complete (err, order)->
            order.amount.should.eql 5
            order.matched_amount.should.eql 5
            order.result_amount.should.eql 0.499
            order.fee.should.eql 0.001
            order.unit_price.should.eql 0.1
            order.status.should.eql "completed"
            done()

      it "sets the balances of the matched order wallets", (done)->
        request('http://localhost:6000')
        .post("/orders_match")
        .send(matchData)
        .expect(200)
        .end ()->
          GLOBAL.db.Wallet.find(1).complete (err, sellWallet)->
            GLOBAL.db.Wallet.find(2).complete (err, buyWallet)->
              sellWallet.balance.should.eql 9
              sellWallet.hold_balance.should.eql 0.5
              buyWallet.balance.should.eql 4.99
              buyWallet.hold_balance.should.eql 0
              done()

      it "sets the balances of the matching order wallets", (done)->
        request('http://localhost:6000')
        .post("/orders_match")
        .send(matchData)
        .expect(200)
        .end ()->
          GLOBAL.db.Wallet.find(3).complete (err, buyWallet)->
            GLOBAL.db.Wallet.find(4).complete (err, sellWallet)->
              sellWallet.balance.should.eql 5
              sellWallet.hold_balance.should.eql 0
              buyWallet.balance.should.eql 0.499
              buyWallet.hold_balance.should.eql 0
              done()

      it "adjusts the market price for the completed order", (done)->
        request('http://localhost:6000')
        .post("/orders_match")
        .send(matchData)
        .expect(200)
        .end ()->
          setTimeout ()->
              GLOBAL.db.MarketStats.getStats (err, stats)->
                stats["LTC_BTC"].growth_ratio.should.eql 100
                stats["LTC_BTC"].last_price.should.eql 0.1
                stats["LTC_BTC"].day_high.should.eql 0.1
                stats["LTC_BTC"].day_low.should.eql 0.1
                stats["LTC_BTC"].volume1.should.eql 5
                stats["LTC_BTC"].volume2.should.eql 0.5
                new Date(stats["LTC_BTC"].today).getDate().should.eql new Date().getDate()
                done()
            , 500


    describe "When a valid match order is coming in with a lower unit price than the one set", ()->
      beforeEach (done)->
        wallets = [
          {id: 1, user_id: 1, currency: "BTC", balance: 9, hold_balance: 1}
          {id: 2, user_id: 1, currency: "LTC", balance: 0}
          {id: 3, user_id: 2, currency: "BTC", balance: 0}
          {id: 4, user_id: 2, currency: "LTC", balance: 5, hold_balance: 5}
        ]
        orders = [
          {id: 1, user_id: 1, type: "limit", action: "buy", buy_currency: "LTC", sell_currency: "BTC", amount: 10, unit_price: 0.1, status: "open", published: true}
          {id: 2, user_id: 2, type: "limit", action: "sell", buy_currency: "BTC", sell_currency: "LTC", amount: 5, unit_price: 0.05, status: "open", published: true}
        ]
        GLOBAL.db.Wallet.bulkCreate(wallets).complete ()->
          GLOBAL.db.Order.bulkCreate(orders).complete ()->
            done()

      matchData =
        [
          {id: 1, order_id: 1, matched_amount: 500000000, result_amount: 499000000, fee: 1000000, unit_price: 5000000, status: 'partiallyCompleted'}
          {id: 2, order_id: 2, matched_amount: 500000000, result_amount: 24950000, fee: 50000, unit_price: 5000000, status: 'completed'}
        ]
      
      it "returns 200 ok", (done)->
        request('http://localhost:6000')
        .post("/orders_match")
        .send(matchData)
        .expect(200)
        .end done

      it "sets the matched order data", (done)->
        request('http://localhost:6000')
        .post("/orders_match")
        .send(matchData)
        .expect(200)
        .end ()->
          GLOBAL.db.Order.find(1).complete (err, order)->
            order.amount.should.eql 10
            order.matched_amount.should.eql 5
            order.result_amount.should.eql 4.99
            order.fee.should.eql 0.01
            order.unit_price.should.eql 0.1
            order.status.should.eql "partiallyCompleted"
            done()

      it "sets the matching order data", (done)->
        request('http://localhost:6000')
        .post("/orders_match")
        .send(matchData)
        .expect(200)
        .end ()->
          GLOBAL.db.Order.find(2).complete (err, order)->
            order.amount.should.eql 5
            order.matched_amount.should.eql 5
            order.result_amount.should.eql 0.2495
            order.fee.should.eql 0.0005
            order.unit_price.should.eql 0.05
            order.status.should.eql "completed"
            done()

      it "sets the balances of the matched order wallets", (done)->
        request('http://localhost:6000')
        .post("/orders_match")
        .send(matchData)
        .expect(200)
        .end ()->
          GLOBAL.db.Wallet.find(1).complete (err, sellWallet)->
            GLOBAL.db.Wallet.find(2).complete (err, buyWallet)->
              sellWallet.balance.should.eql 9.25
              sellWallet.hold_balance.should.eql 0.5
              buyWallet.balance.should.eql 4.99
              buyWallet.hold_balance.should.eql 0
              done()

      it "sets the balances of the matching order wallets", (done)->
        request('http://localhost:6000')
        .post("/orders_match")
        .send(matchData)
        .expect(200)
        .end ()->
          GLOBAL.db.Wallet.find(3).complete (err, buyWallet)->
            GLOBAL.db.Wallet.find(4).complete (err, sellWallet)->
              sellWallet.balance.should.eql 5
              sellWallet.hold_balance.should.eql 0
              buyWallet.balance.should.eql 0.2495
              buyWallet.hold_balance.should.eql 0
              done()

      it "adjusts the market price for the completed order", (done)->
        request('http://localhost:6000')
        .post("/orders_match")
        .send(matchData)
        .expect(200)
        .end ()->
          GLOBAL.db.MarketStats.getStats (err, stats)->
            stats["LTC_BTC"].growth_ratio.should.eql 100
            stats["LTC_BTC"].last_price.should.eql 0.05
            stats["LTC_BTC"].day_high.should.eql 0.05
            stats["LTC_BTC"].day_low.should.eql 0.05
            stats["LTC_BTC"].volume1.should.eql 5
            stats["LTC_BTC"].volume2.should.eql 0.25
            new Date(stats["LTC_BTC"].today).getDate().should.eql new Date().getDate()
            done()
