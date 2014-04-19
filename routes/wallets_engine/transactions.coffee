restify = require "restify"
async = require "async"
Wallet = GLOBAL.db.Wallet
Transaction = GLOBAL.db.Transaction
Payment = GLOBAL.db.Payment
JsonRenderer = require "../../lib/json_renderer"
TransactionHelper = require "../../lib/transaction_helper"
paymentsProcessedUserIds = []
_ = require "underscore"

module.exports = (app)->

  app.put "/transaction/:currency/:tx_id", (req, res, next)->
    txId = req.params.tx_id
    currency = req.params.currency
    console.log txId
    console.log currency
    GLOBAL.wallets[currency].getTransaction txId, (err, walletTransaction)->
      subTransactions = _.clone walletTransaction.details
      delete walletTransaction.details
      loadTransactionCallback = (subTransaction, callback)->
        transactionData = _.extend subTransaction, walletTransaction
        TransactionHelper.loadTransaction transactionData, currency, callback
      async.mapSeries subTransactions, loadTransactionCallback, (err, result)->
        console.error err  if err
        res.send("#{new Date()} - Added transactino #{txId} #{currency}")

  app.post "/load_latest_transactions/:currency", (req, res, next)->
    currency = req.params.currency
    GLOBAL.wallets[currency].getTransactions "*", 100, 0, (err, transactions)->
      console.error err  if err
      loadTransactionCallback = (transaction, callback)->
        TransactionHelper.loadTransaction transaction, currency, callback
      return res.send("#{new Date()} - Nothing to process")  if not transactions
      async.mapSeries transactions, loadTransactionCallback, (err, result)->
        console.error err  if err
        res.send("#{new Date()} - Processed #{result.length} transactions")        

  app.post "/process_pending_payments", (req, res, next)->
    TransactionHelper.paymentsProcessedUserIds = []
    Payment.findByStatus "pending", (err, payments)->
      async.mapSeries payments, TransactionHelper.processPayment, (err, result)->
        console.log err  if err
        res.send("#{new Date()} - #{result}")

  app.post "/process_payment/:payment_id", (req, res, next)->
    paymentId = req.params.payment_id
    TransactionHelper.paymentsProcessedUserIds = []
    Payment.findById paymentId, (err, payment)->
      TransactionHelper.processPayment payment, (err, result)->
        Payment.findById paymentId, (err, processedPayment)->
          res.send
            paymentId: paymentId
            status: processedPayment.status
            result: result
          if processedPayment.isProcessed()
            TransactionHelper.pushToUser
              type: "payment-processed"
              user_id: payment.user_id
              eventData: JsonRenderer.payment processedPayment
