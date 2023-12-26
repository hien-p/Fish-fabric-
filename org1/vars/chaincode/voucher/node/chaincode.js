'use strict';

const {Contract} = require('fabric-contract-api');

class CrossChaincode extends Contract { 
        async VoucherExists(ctx, voucher_id){
            let assetState  = await ctx.stub.getState(voucher_id);
            return assetState && assetState.length >  0;
        }
    
      async Readvoucher(ctx, id){
        const assetJson = await ctx.stub.getState(id);
    
        if (!assetJson || assetJson.length == 0){
          throw new Error('voucher does not exist');
        } 
    
        return assetJson.toString();
    
      }
    
      async CreateVoucher(ctx, key, citizen_id, supplier_id, dealer_id, type, status, value, package_id, created_at, updated_at, validDate)
      {
        //Check if voucher exists
        const exists = await this.VoucherExists(ctx, key);
        if (exists) {
            throw new Error('The voucher ${key} already exists');
        }
    
        //Create voucher object
        let voucher = {
            docType: 'voucher',
            voucher_id: key,
            citizen_id: citizen_id,
            supplier_id: supplier_id,
            dealer_id: dealer_id,
            status: status,
            value: value,
            type: type,
            package_id: package_id,
            created_at: created_at,
            updated_at: updated_at,
            valid_date: validDate,
        };
    
        //Save voucher to state database
        await ctx.stub.putState(key, Buffer.from(JSON.stringify(voucher)));
    
        //Create and save voucherCitizenIndexKey
        let indexName = 'voucher_id~citizen_id' ;
        let voucherCitizenIndexKey = await ctx.stub.createCompositeKey(indexName,[voucher.voucher_id, voucher.citizen_id]);
        await ctx.stub.putState(voucherCitizenIndexKey, Buffer.from('\u0000')); //add index to database
      }
    
      // Initialize the chaincode
      async InitLedger(ctx) {
        const assets = [
           { id: "133", citizen_id: "123", supplier_id: "123",
           dealer_id: "123", status: "UNUSE", value: "123", package_id: "123",
           created_at: new Date().toString(), updated_at: new Date().toString() }
        ];
    
        for (const asset of assets) {
           await this.CreateVoucher(
             ctx,
             asset.id,
             asset.citizen_id,
             asset.supplier_id,
             asset.dealer_id,
             asset.status,
             asset.value,
             asset.package_id,
             asset.created_at,
             asset.updated_at
           );
        }
       }    
}
module.exports = CrossChaincode;