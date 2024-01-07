import Debug "mo:base/Debug";
import Cycles "mo:base/ExperimentalCycles";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import Error "mo:base/Error";
// import env "env/lib.mo";
import Iter "mo:base/Iter";

import Types "Types";
import Option "mo:base/Option";
import Nat "mo:base/Nat";
import Float "mo:base/Float";
import Buffer "mo:base/Buffer";
import ExperimentalCycles "mo:base/ExperimentalCycles";

actor {
    type CoinGecko = object {
        gecko_says : Text;
    };

    var textBuffer = Buffer.Buffer<Text>(0);
    type Pattern = { #char : Char; #text : Text; #predicate : (Char -> Bool) };

    public func get_btc_usd_data(/* tokenSymbol: Text, baseCurrency: Text */) : async Text {
        //1. DECLARE IC MANAGEMENT CANISTER
        let ic : Types.IC = actor ("aaaaa-aa");

        //2. SETUP ARGUMENTS FOR HTTP GET request

        // let host : Text = "pro-api.coinmarketcap.com";
        // let url : Text = "https://" # host #"/v1/cryptocurrency/quotes/latest";
        // let url : Text = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?symbol=" # tokenSymbol # "&CMC_PRO_API_KEY=9d29f572-d2dc-4ae0-b041-14a01037624b&convert=" # baseCurrency;
        // let url : Text = "https://pro-api.coinmarketcap.com/v2/cryptocurrency/quotes/latest?symbol=BTC&CMC_PRO_API_KEY=9d29f572-d2dc-4ae0-b041-14a01037624b&convert=USD";
        // let url : Text = "https://pro-api.coinmarketcap.com/v2/cryptocurrency/quotes/historical?symbol=" # tokenSymbol # "&CMC_PRO_API_KEY=9d29f572-d2dc-4ae0-b041-14a01037624b&convert=" # baseCurrency;

        // let url : Text = "https://pro-api.coinmarketcap.com/v2/cryptocurrency/quotes/historical" # "?symbol=BTC" # "&time=2022-06-01T00:00:00Z"  # "&convert=USD" # "&CMC_PRO_API_KEY=9d29f572-d2dc-4ae0-b041-14a01037624b";

        ///       custom header named                      test API Key
        // let request_header = [{ name= "CMC_PRO_API_KEY"; value= "b54bcf4d-1bca-4e8e-9a24-22ff2c3d462c"}];

        let url : Text = "https://api.coingecko.com/api/v3/ping";

        // 2.3 The HTTP request
        let httpRequestArgs : Types.HttpRequestArgs = {
            url = url;
            max_response_bytes = null;
            headers = /* request_header */ [];
            body = null;
            method = #get;
            transform = null;
        };

        //3. ADD CYCLES TO PAY FOR HTTP REQUEST
        Cycles.add(220_131_200_000);

        //4. MAKE HTTPS REQUEST AND WAIT FOR RESPONSE
        let http_response : Types.HttpResponsePayload = await ic.http_request(httpRequestArgs);

        //5. DECODE THE RESPONSE
        //public type HttpResponsePayload = {
        //     status : Nat; 
        //     headers : [HttpHeader];
        //     body : [Nat8];
        // };
        let response_body = Blob.fromArray(http_response.body);
        let decode_text : Text = switch (Text.decodeUtf8(response_body)) {
            case (null) { "No value returned" };
            case (?value) { value };
        };

        // let aa = to_candid(decode_text);
        // let deserialized_data : ?CoinGecko = from_candid(response_body);
        // return decode_text;
        // (response_body, deserialized_data) ;
        // decode_text;

        return decode_text;

        // return http_response.headers;
        // return decode_text;

    };

    public func check(index : Nat) : async (Text, [Nat], Float) {

        let textIter = Text.split(textBuffer.get(index), #char '.');

        let numberArray : [Nat] = Array.map(Iter.toArray(textIter), func(t : Text) : Nat = switch (Nat.fromText(t)) { case (null) { 0 }; case (?v) { v } });
        //////////////
        /// Price to Float conversion from Text
        let priceTextArray = Iter.toArray(Text.split(textBuffer.get(index), #char '.'));
        let priceIntegral : Int = Option.get(Nat.fromText(priceTextArray[0]), 0);
        let fractionLength : Nat = Text.size(priceTextArray[1]);
        let priceFractional : Int = Option.get(Nat.fromText(priceTextArray[1]), 0);
        let price : Float = Float.fromInt(priceIntegral) + (Float.fromInt(priceFractional) / (10 ** Float.fromInt(fractionLength)));

        (textBuffer.get(index), numberArray, price);
    };

    public func get_btc_usd_price(index : Nat) : async Float {
        let body = await get_btc_usd_data();

        return (await check(index)).2;
    };

    public func getBalance() : async Nat {
        ExperimentalCycles.balance();
    };

};
