# encoding: UTF-8

require "cuba"
require_relative "lib/mercadoauth"

client_id = ""
client_secret = ""

Cuba.define do
  meli = MercadoAuth.new(client_id, client_secret)

  on "callback" do
    meli.redirect_uri = ""
    access_token = meli.access_token(req.GET["code"])

    res.write JSON.parse(meli.get("/users/me"))
  end

  on root do
    res.write meli.authorize_url
  end
end

