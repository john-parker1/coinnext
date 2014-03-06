fs = require "fs"
environment = process.env.NODE_ENV or 'development'
config = JSON.parse(fs.readFileSync(process.cwd() + '/config.json', 'utf8'))[environment]
GLOBAL.appConfig = ()-> config
async = require "async"
_ = require "underscore"

task "db:ensure_indexes", "Create indexes for all the collections", ()->
  require('./models/db_connect_mongo')
  _s         = require "underscore.string"
  modelNames = [
    "User", "Chat", "MarketStats", "Order", "Payment",
    "Transaction", "Wallet"
  ]
  for modelName in modelNames
    model = require "./models/#{_s.underscored(modelName)}"
    model.ensureIndexes()

task "db:seed_market_stats", "Seed default market stats", ()->
  require('./models/db_connect_mongo')
  MarketStats = require "./models/market_stats"
  MarketStats.collection.drop (err) ->
    marketStats = [
      {type: "LTC_BTC", label: "LTC"}
      {type: "PPC_BTC", label: "PPC"}
    ]
    saveMarket = (market, cb)->
      MarketStats.create market, cb
    async.mapSeries marketStats, saveMarket, (err, result)->
      console.log result
      mongoose.connection.close()

task "db:seed_trade_stats", "Seed default trade stats", ()->
  require('./models/db_connect_mongo')
  TradeStats = require "./models/trade_stats"
  TradeStats.collection.drop (err) ->
    tradeStats = [
      {type: 'LTC_BTC', open_price: 779.84, close_price: 780, high_price: 780.9, low_price: 773.081, volume: 68.31826722}
      {type: 'LTC_BTC', open_price: 780.9, close_price: 779.84, high_price: 781, low_price: 778.103, volume: 51.38206402}
      {type: 'LTC_BTC', open_price: 777.039, close_price: 781, high_price: 781.984, low_price: 776.011, volume: 83.14108012}
      {type: 'LTC_BTC', open_price: 774, close_price: 777.81, high_price: 779.459, low_price: 771.44, volume: 181.90308203}
      {type: 'LTC_BTC', open_price: 773.95, close_price: 774.08, high_price: 776, low_price: 771.5, volume: 55.47094078}
      {type: 'LTC_BTC', open_price: 774, close_price: 773.95, high_price: 777.775, low_price: 772.5, volume: 58.71336455}
      {type: 'LTC_BTC', open_price: 774.561, close_price: 774, high_price: 776.499, low_price: 771.442, volume: 67.69171032}
      {type: 'LTC_BTC', open_price: 772.5, close_price: 774, high_price: 775.024, low_price: 769.012, volume: 171.65156336}
      {type: 'LTC_BTC', open_price: 767.01, close_price: 769.012, high_price: 772.8, low_price: 767, volume: 92.00133851}
      {type: 'LTC_BTC', open_price: 765.002, close_price: 767.01, high_price: 770, low_price: 765.002, volume: 76.88759789}
      {type: 'LTC_BTC', open_price: 761.1, close_price: 766.099, high_price: 766.099, low_price: 761.01, volume: 439.46252646}
      {type: 'LTC_BTC', open_price: 766.3, close_price: 761.1, high_price: 767.993, low_price: 761.01, volume: 108.1900767}
      {type: 'LTC_BTC', open_price: 761, close_price: 764.3, high_price: 766.3, low_price: 761, volume: 201.48534192}
      {type: 'LTC_BTC', open_price: 762.04, close_price: 763.671, high_price: 764.99, low_price: 761.001, volume: 102.65387933}
      {type: 'LTC_BTC', open_price: 764.857, close_price: 764.989, high_price: 764.989, low_price: 762, volume: 106.62740328}
      {type: 'LTC_BTC', open_price: 761.9, close_price: 764.98, high_price: 765.95, low_price: 760, volume: 107.01773136}
      {type: 'LTC_BTC', open_price: 762.479, close_price: 760.3, high_price: 764.5, low_price: 760.051, volume: 76.33992603}
      {type: 'LTC_BTC', open_price: 754.987, close_price: 762, high_price: 762, low_price: 753.99, volume: 233.90507099}
      {type: 'LTC_BTC', open_price: 738.999, close_price: 754.987, high_price: 755, low_price: 735.23, volume: 902.09223436999}
      {type: 'LTC_BTC', open_price: 740.22, close_price: 738.999, high_price: 754.788, low_price: 735.23, volume: 467.97145301}
      {type: 'LTC_BTC', open_price: 725.005, close_price: 741.125, high_price: 741.125, low_price: 725, volume: 1228.64581651}
      {type: 'LTC_BTC', open_price: 734, close_price: 725.005, high_price: 738.86, low_price: 722.222, volume: 599.37747294}
      {type: 'LTC_BTC', open_price: 733.574, close_price: 736.537, high_price: 739.899, low_price: 732, volume: 403.02641668}
      {type: 'LTC_BTC', open_price: 736, close_price: 733.201, high_price: 743.28, low_price: 728.001, volume: 205.26895699}
      {type: 'LTC_BTC', open_price: 736.2, close_price: 736, high_price: 740.17, low_price: 735.102, volume: 310.27347296}
      {type: 'LTC_BTC', open_price: 720.7, close_price: 736.2, high_price: 737.539, low_price: 720, volume: 665.61072276}
      {type: 'LTC_BTC', open_price: 714.5, close_price: 720.7, high_price: 722.999, low_price: 706.59, volume: 1013.48560361}
      {type: 'LTC_BTC', open_price: 719.8, close_price: 714.5, high_price: 722.999, low_price: 712.4, volume: 333.28169499}
      {type: 'LTC_BTC', open_price: 701.49, close_price: 719.684, high_price: 734, low_price: 690, volume: 2208.99443381}
      {type: 'LTC_BTC', open_price: 725, close_price: 701.49, high_price: 740, low_price: 679.8, volume: 2485.21726338}
      {type: 'LTC_BTC', open_price: 708, close_price: 727.477, high_price: 730, low_price: 693, volume: 1797.7043145}
      {type: 'LTC_BTC', open_price: 703, close_price: 710.4, high_price: 725.584, low_price: 676.1, volume: 2512.55904813}
      {type: 'LTC_BTC', open_price: 708.782, close_price: 702, high_price: 725, low_price: 689.664, volume: 1638.63514872}
      {type: 'LTC_BTC', open_price: 710.522, close_price: 708.782, high_price: 718.5, low_price: 698, volume: 1102.45756224}
      {type: 'LTC_BTC', open_price: 703, close_price: 712, high_price: 719, low_price: 702.49, volume: 809.81615886}
      {type: 'LTC_BTC', open_price: 699.7, close_price: 703, high_price: 707.66, low_price: 697.1, volume: 535.51401961}
      {type: 'LTC_BTC', open_price: 695.5, close_price: 699.7, high_price: 709.999, low_price: 688.2, volume: 611.48052543}
      {type: 'LTC_BTC', open_price: 708.99, close_price: 696.675, high_price: 711.9, low_price: 696.675, volume: 423.33686581}
      {type: 'LTC_BTC', open_price: 714.998, close_price: 708.99, high_price: 715, low_price: 701.506, volume: 447.39458863}
      {type: 'LTC_BTC', open_price: 711, close_price: 714.998, high_price: 714.999, low_price: 706, volume: 516.17074954}
      {type: 'LTC_BTC', open_price: 701.537, close_price: 711, high_price: 711.8, low_price: 701.537, volume: 388.55169839}
      {type: 'LTC_BTC', open_price: 718.999, close_price: 701.504, high_price: 719, low_price: 700, volume: 686.158724}
      {type: 'LTC_BTC', open_price: 724.999, close_price: 718.4, high_price: 729.3, low_price: 715.65, volume: 763.43130188}
      {type: 'LTC_BTC', open_price: 730.6, close_price: 724.999, high_price: 737, low_price: 722.5, volume: 598.79273912}
      {type: 'LTC_BTC', open_price: 733.1, close_price: 733, high_price: 734, low_price: 725.658, volume: 266.10094641}
      {type: 'LTC_BTC', open_price: 726.065, close_price: 733.237, high_price: 734.899, low_price: 725, volume: 222.04022134}
      {type: 'LTC_BTC', open_price: 722.001, close_price: 726.065, high_price: 726.9, low_price: 716, volume: 406.90472449}
      {type: 'LTC_BTC', open_price: 724.872, close_price: 723, high_price: 726.499, low_price: 720.011, volume: 120.37654008}
      {type: 'LTC_BTC', open_price: 724.372, close_price: 724.372, high_price: 724.372, low_price: 724.372, volume: 0.05}
      
      {type: "PPC_BTC", open_price: 0.00664, close_price: 0.00665, high_price: 0.00666, low_price: 0.00664, volume: 232.1904831}
      {type: "PPC_BTC", open_price: 0.00665, close_price: 0.00713, high_price: 0.00865, low_price: 0.00564, volume: 567.1904831}
      {type: "PPC_BTC", open_price: 0.00713, close_price: 0.00508, high_price: 0.00899, low_price: 0.00264, volume: 827.1904831}
    ]
    now = Date.now()
    halfHour = 1800000
    oneDay = 86400000
    endTime =  now - now % halfHour
    startTime = endTime - oneDay
    startTimes =
      LTC_BTC: startTime
      PPC_BTC: startTime
    saveStats = (st, cb)->
      st.start_time = startTimes[st.type]
      st.end_time = st.start_time + halfHour
      startTimes[st.type] = st.end_time
      TradeStats.create st, cb
    async.mapSeries tradeStats, saveStats, (err, result)->
      console.log result
      mongoose.connection.close()

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
  ###
  orderSocket = new ClientSocket
    host: GLOBAL.appConfig().app_host
    path: "orders"
  require('./models/db_connect_mongo')
  Order = require "./models/order"
  Order.findById "5308a9944a49327ab9ba0b2b", (err, order)->
    order.status = "partiallyCompleted"
    order.unit_price = 0.1
    order.sold_amount = 5
    order.result_amount = 0.5
    orderSocket.send
      type: "order-partially-completed"
      eventData: JsonRenderer.order order
    setTimeout ()->
        orderSocket.close()
        mongoose.connection.close()
      , 1000
  ###