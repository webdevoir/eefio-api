require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do

  describe "GET #show" do
    it "returns http success" do
      get :show
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #raw" do
    it "returns http success" do
      get :raw
      expect(response).to have_http_status(:success)
    end
  end

end
