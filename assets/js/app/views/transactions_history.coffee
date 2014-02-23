class App.TransactionsHistoryView extends App.MasterView

  tpl: "transaction-history-tpl"

  collection: null

  initialize: (options = {})->
    $.subscribe "payment-processed", @onPaymentProcessed
    $.subscribe "transaction-update", @onTransactionUpdate

  render: ()->
    @collection.fetch
      success: ()=>
        @collection.each (transaction)=>
          @$el.append @template
            transaction: transaction

  onTransactionUpdate: (ev, transaction)=>
    @$el.empty()
    @render()  if not @$("[data-id='#{transaction.id}']").length

  onPaymentProcessed: (ev, payment)=>
    @$el.empty()
    @render()  if not @$("[data-id='#{payment.id}']").length
