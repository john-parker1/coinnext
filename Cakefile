fs = require "fs"
environment = process.env.NODE_ENV or 'development'
config = JSON.parse(fs.readFileSync(process.cwd() + '/config.json', 'utf8'))[environment]
GLOBAL.appConfig = ()-> config
GLOBAL.db = require './models/index'

task "db:create_tables", "Create all tables", ()->
  GLOBAL.db.sequelize.sync().complete ()->

task "db:create_tables_force", "Drop and create all tables", ()->
  return console.log "Not in production!"  if environment is "production"
  GLOBAL.db.sequelize.sync({force: true}).complete ()->

task "db:seed_market_stats", "Seed default market stats", ()->
  MarketStats = GLOBAL.db.MarketStats
  marketStats = require './models/seeds/market_stats'
  GLOBAL.db.sequelize.query("TRUNCATE TABLE #{MarketStats.tableName}").complete ()->
    MarketStats.bulkCreate(marketStats).success ()->
      MarketStats.findAll().success (result)->
        console.log JSON.stringify result

task "db:seed_trade_stats", "Seed default trade stats", ()->
  TradeStats = GLOBAL.db.TradeStats
  tradeStats = require './models/seeds/trade_stats'
  now = Date.now()
  halfHour = 1800000
  oneDay = 86400000
  endTime =  now - now % halfHour
  startTime = endTime - oneDay
  startTimes =
    LTC_BTC: startTime
    PPC_BTC: startTime
  for stat in tradeStats
    stat.start_time = startTimes[stat.type]
    stat.end_time = stat.start_time + halfHour
    startTimes[stat.type] = stat.end_time
  GLOBAL.db.sequelize.query("TRUNCATE TABLE #{TradeStats.tableName}").complete ()->
    TradeStats.bulkCreate(tradeStats).success ()->
      TradeStats.findAll().success (result)->
        console.log JSON.stringify result

task "test_sockets", "Send socket messages", ()->
  JsonRenderer = require "./lib/json_renderer"
  ClientSocket = require "./lib/client_socket"
  usersSocket = new ClientSocket
    host: GLOBAL.appConfig().app_host
    path: "users"
  require('./models/db_connect_mongo')
  Wallet = require "./models/wallet"
  Wallet.findById "52c2f94d83c42a0000000001", (err, wallet)->
    wallet.balance = 10
    wallet.hold_balance = 15
    usersSocket.send
      type: "wallet-balance-loaded"
      user_id: wallet.user_id
      eventData: JsonRenderer.wallet wallet
    setTimeout ()->
        usersSocket.close()
        mongoose.connection.close()
      , 1000
