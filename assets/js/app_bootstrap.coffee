$(document).ready ()->

  $.tmpload.defaults.tplWrapper = _.template

  _.str.roundTo = (number, decimals = 8)->
    multiplier = Math.pow(10, decimals)
    Math.round(parseFloat(number) * multiplier) / multiplier

  _.str.satoshiRound = (number)->
    _.str.roundTo number, 8

  errorLogger = new App.ErrorLogger

  user = new App.UserModel
  user.fetch
    success: ()->
      if user.id
        usersSocket = io.connect "#{CONFIG.users.hostname}/users"
        usersSocket.on "connect", ()=>
          usersSocket.emit "listen", {id: user.id}
        usersSocket.on "payment-processed", (data)=>
          payment = new App.PaymentModel data
          $.publish "payment-processed", payment
        usersSocket.on "transaction-update", (data)=>
          transaction = new App.TransactionModel data
          $.publish "transaction-update", transaction
        usersSocket.on "wallet-balance-loaded", (data)=>
          wallet = new App.WalletModel data
          $.publish "wallet-balance-loaded", wallet

  $qrGenBt = $("#qr-gen-bt")

  if $qrGenBt.length
    $qrGenBt.click (ev)->
      ev.preventDefault()
      if confirm "Are you sure?"
        $.get $qrGenBt.attr("href"), ()->
          window.location.reload()

  $marketTicker = $("#market-ticker")
  if $marketTicker.length
    marketTicker = new App.MarketTickerView
      el: $marketTicker
      model: new App.MarketStatsModel
    marketTicker.render()

  # Funds page
  $finances = $("#finances")
  if $finances.length
    finances = new App.FinancesView
      el: $finances
      collection: new App.WalletsCollection
    finances.render()

    $pendingTransactions = $("#pending-transactions-cnt")
    if $pendingTransactions.length
      pendingTransactions = new App.PendingTransactionsView
        el: $pendingTransactions
        collection: new App.TransactionsCollection null,
          type: "pending"
          walletId: $pendingTransactions.data "wallet-id"
        payments: new App.PaymentsCollection null,
          type: "pending"
          walletId: $pendingTransactions.data "wallet-id"
      pendingTransactions.render()

    $transactionsHistory = $("#transactions-history-cnt")
    if $transactionsHistory.length
      transactionsHistory = new App.TransactionsHistoryView
        el: $transactionsHistory
        collection: new App.TransactionsCollection null,
          type: "processed"
          walletId: $transactionsHistory.data "wallet-id"
      transactionsHistory.render()

    $openOrders = $("#open-orders-cnt")
    if $openOrders.length
      openOrders = new App.OrdersView
        el: $openOrders
        tpl: "wallet-open-order-tpl"
        collection: new App.OrdersCollection null,
          type: "open"
          currency1: $openOrders.data "currency1"
          userId: CONFIG.currentUser.id
      openOrders.render()

    $closedOrders = $("#closed-orders-cnt")
    if $closedOrders.length
      closedOrders = new App.OrdersView
        el: $closedOrders
        tpl: "wallet-closed-order-tpl"
        collection: new App.OrdersCollection null,
          type: "completed"
          currency1: $closedOrders.data "currency1"
          userId: CONFIG.currentUser.id
      closedOrders.render()

    $overviewOpenOrders = $("#overview-open-orders-cnt")
    if $overviewOpenOrders.length
      overviewOpenOrders = new App.OrdersView
        el: $overviewOpenOrders
        tpl: "wallet-open-order-tpl"
        collection: new App.OrdersCollection null,
          type: "open"
          userId: CONFIG.currentUser.id
      overviewOpenOrders.render()

    $overviewClosedOrders = $("#overview-closed-orders-cnt")
    if $overviewClosedOrders.length
      overviewClosedOrders = new App.OrdersView
        el: $overviewClosedOrders
        tpl: "wallet-closed-order-tpl"
        collection: new App.OrdersCollection null,
          type: "completed"
          userId: CONFIG.currentUser.id
      overviewClosedOrders.render()


  # Trade page
  $trade = $("#trade")
  if $trade.length
    trade = new App.TradeView
      el: $trade
      model: new App.MarketStatsModel
      currency1: $trade.data "currency1"
      currency2: $trade.data "currency2"
    trade.render()

    tradeChart = new App.TradeChartView
      el: $trade.find("#trade-chart")
      collection: new App.TradeStatsCollection null,
        type: "#{$trade.data('currency1')}_#{$trade.data('currency2')}"
    tradeChart.render()

    $openOrders = $("#open-orders-cnt")
    openOrders = new App.OrdersView
      el: $openOrders
      tpl: "open-order-tpl"
      collection: new App.OrdersCollection null,
        type: "open"
        currency1: $openOrders.data "currency1"
        currency2: $openOrders.data "currency2"
        userId: CONFIG.currentUser.id
    openOrders.render()

    $openSellOrders = $("#open-sell-orders-cnt")
    openSellOrders = new App.OrdersView
      el: $openSellOrders
      tpl: "site-open-order-tpl"
      $totalsEl: $trade.find("#open-sell-volume-total")
      collection: new App.OrdersCollection null,
        type: "open"
        action: "sell"
        currency1: $openSellOrders.data "currency1"
        currency2: $openSellOrders.data "currency2"
    openSellOrders.render()

    $openBuyOrders = $("#open-buy-orders-cnt")
    openBuyOrders = new App.OrdersView
      el: $openBuyOrders
      tpl: "site-open-order-tpl"
      $totalsEl: $trade.find("#open-buy-volume-total")
      collection: new App.OrdersCollection null,
        type: "open"
        action: "buy"
        currency1: $openBuyOrders.data "currency1"
        currency2: $openBuyOrders.data "currency2"
    openBuyOrders.render()

    $closedOrders = $("#closed-orders-cnt")
    closedOrders = new App.OrdersView
      el: $closedOrders
      tpl: "site-closed-order-tpl"
      collection: new App.OrdersCollection null,
        type: "completed"
        currency1: $openBuyOrders.data "currency1"
        currency2: $openBuyOrders.data "currency2"
    closedOrders.render()

  ordersSocket = io.connect "#{CONFIG.users.hostname}/orders"
  ordersSocket.on "connect", ()->
  ordersSocket.on "order-published", (data)->
    order = new App.OrderModel data
    $.publish "new-order", order
  ordersSocket.on "order-completed", (data)->
    order = new App.OrderModel data
    $.publish "order-completed", order
  ordersSocket.on "order-partially-completed", (data)->
    order = new App.OrderModel data
    $.publish "order-partially-completed", order
  ordersSocket.on "order-canceled", (data)->
    $.publish "order-canceled", data
  ordersSocket.on "market-stats-updated", (data)->
    $.publish "market-stats-updated", data
