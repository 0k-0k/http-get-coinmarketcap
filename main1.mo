import Debug "mo:base/Debug";
import Cycles "mo:base/ExperimentalCycles";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import Error "mo:base/Error";
// import env "env/lib.mo";


import Types "Types";

actor {
    public func get_price_now() : async Text{
        //1. DECLARE IC MANAGEMENT CANISTER
        let ic : Types.IC = actor("aaaaa-aa");

        //2. SETUP ARGUMENTS FOR HTTP GET request
        // https://sandbox-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?symbol=BTC&CMC_PRO_API_KEY=b54bcf4d-1bca-4e8e-9a24-22ff2c3d462c&convert=USD

        let host : Text = "pro-api.coinmarketcap.com";
        // let url : Text = "https://" # host #"/v1/cryptocurrency/quotes/latest";
        // let url : Text = "https://pro-api.coinmarketcap.com/v2/cryptocurrency/quotes/latest?symbol=" # tokenSymbol # "&convert=" # baseCurrency;
        // let url : Text = "https://pro-api.coinmarketcap.com/v2/cryptocurrency/quotes/historical?symbol=ICP&time_start=1688153100&time_end=1688153100&interval=1m&CMC_PRO_API_KEY=9d29f572-d2dc-4ae0-b041-14a01037624b&convert=USD";
        let url : Text = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/historical?symbol=BTC&time_start=2023-07-02T14:32:00.000Z&time_end=2023-07-02T14:32:00.000Z&CMC_PRO_API_KEY=9d29f572-d2dc-4ae0-b041-14a01037624b";

        let request_header = [
            { name = "CMC_PRO_API_KEY" ; value = "9d29f572-d2dc-4ae0-b041-14a01037624b"}
            // { name= "Accepts"; value= "application/json"}
        ];

          // 2.3 The HTTP request
        let httpRequestArgs : Types.HttpRequestArgs = {
            url = url;
            max_response_bytes = null;
            headers = request_header ; 
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
        let decode_text : Text = switch(Text.decodeUtf8(response_body )) {
            case(null) { "No value returned" };
            case(?value) { value};
        };
        return decode_text;

    }
}

