describe MangoPay::Transaction do
  include_context 'wallets'
  include_context 'payins'
  include_context 'payouts'

  describe 'FETCH' do

    it 'fetches empty list of transactions if no transactions done' do
      transactions = MangoPay::Transaction.fetch(new_wallet['Id'])
      expect(transactions).to be_kind_of(Array)
      expect(transactions).to be_empty
    end

    it 'fetches list with single transaction after payin done' do
      payin = new_payin_card_direct
      transactions = MangoPay::Transaction.fetch(new_wallet['Id'])
      expect(transactions).to be_kind_of(Array)
      expect(transactions.count).to eq 1
      expect(transactions.first['Id']).to eq payin['Id']
    end

    it 'fetches list with two transactions after payin and payout done' do
      payin = new_payin_card_direct
      payout = create_new_payout_bankwire(payin)
      # wait for the transactions to be created
      sleep(2)
      transactions = MangoPay::Transaction.fetch(new_wallet['Id'])

      expect(transactions).to be_kind_of(Array)
      expect(transactions.count).to eq 2

      transactions_ids = transactions.map {|t| t['Id']}
      expect(transactions_ids).to include payin['Id']
      expect(transactions_ids).to include payout['Id']
    end

    it 'accepts filtering params' do
      payin = new_payin_card_direct
      payout = create_new_payout_bankwire(payin)
      wallet_id = new_wallet['Id']

      # wait for the transactions to be created
      sleep(2)

      by_nature_reg = MangoPay::Transaction.fetch(wallet_id, {'Nature' => 'REGULAR'})
      by_nature_ref = MangoPay::Transaction.fetch(wallet_id, {'Nature' => 'REFUND'})
      expect(by_nature_reg.count).to eq 2
      expect(by_nature_ref.count).to eq 0

      by_type_pyin  = MangoPay::Transaction.fetch(wallet_id, {'Type' => 'PAYIN'})
      by_type_pyout = MangoPay::Transaction.fetch(wallet_id, {'Type' => 'PAYOUT'})
      expect(by_type_pyin.count).to eq 1
      expect(by_type_pyout.count).to eq 1
      expect(by_type_pyin.first['Id']).to eq payin['Id']
      expect(by_type_pyout.first['Id']).to eq payout['Id']
    end

  end
end
