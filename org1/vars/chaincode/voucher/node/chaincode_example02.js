/*
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
*/

const shim = require('fabric-shim');
const util = require('util');

var Chaincode = class {

  // Initialize the chaincode
  async Init(stub) {
    console.info('========= example02 Init =========');
    let ret = stub.getFunctionAndParameters();
    console.info(ret);
    let args = ret.params;
    // initialise only if 4 parameters passed.
    if (args.length != 4) {
      return shim.error('Incorrect number of arguments. Expecting 4');
    }

    let A = args[0];
    let B = args[2];
    let Aval = args[1];
    let Bval = args[3];

    if (typeof parseInt(Aval) !== 'number' || typeof parseInt(Bval) !== 'number') {
      return shim.error('Expecting integer value for asset holding');
    }

    try {
      await stub.putState(A, Buffer.from(Aval));
      try {
        await stub.putState(B, Buffer.from(Bval));
        return shim.success();
      } catch (err) {
        return shim.error(err);
      }
    } catch (err) {
      return shim.error(err);
    }
  }

  async Invoke(stub) {
    let ret = stub.getFunctionAndParameters();
    console.info(ret);
    let method = this[ret.fcn];
    if (!method) {
      console.log('no method of name:' + ret.fcn + ' found');
      return shim.success();
    }
    try {
      let payload = await method(stub, ret.params);
      return shim.success(payload);
    } catch (err) {
      console.log(err);
      return shim.error(err);
    }
  }
  
  async invoke(stub, args) {
    if (args.length != 3) {
      throw new Error('Incorrect number of arguments. Expecting 3');
    }

    let A = args[0];
    let B = args[1];
    if (!A || !B) {
      throw new Error('asset holding must not be empty');
    }

    // Get the state from the ledger
    let Avalbytes = await stub.getState(A);
    if (!Avalbytes) {
      throw new Error('Failed to get state of asset holder A');
    }
    let Aval = parseInt(Avalbytes.toString());

    let Bvalbytes = await stub.getState(B);
    if (!Bvalbytes) {
      throw new Error('Failed to get state of asset holder B');
    }

    let Bval = parseInt(Bvalbytes.toString());
    // Perform the execution
    let amount = parseInt(args[2]);
    if (typeof amount !== 'number') {
      throw new Error('Expecting integer value for amount to be transaferred');
    }

    Aval = Aval - amount;
    Bval = Bval + amount;
    console.info(util.format('Aval = %d, Bval = %d\n', Aval, Bval));

    // Write the states back to the ledger
    await stub.putState(A, Buffer.from(Aval.toString()));
    await stub.putState(B, Buffer.from(Bval.toString()));

  }

  // Deletes an entity from state
  async delete(stub, args) {
    if (args.length != 1) {
      throw new Error('Incorrect number of arguments. Expecting 1');
    }

    let A = args[0];

    // Delete the key from the state in ledger
    await stub.deleteState(A);
  }

  // query callback representing the query of a chaincode
  async query(stub, args) {
    if (args.length != 1) {
      throw new Error('Incorrect number of arguments. Expecting name of the person to query')
    }

    let jsonResp = {};
    let A = args[0];

    // Get the state from the ledger
    let Avalbytes = await stub.getState(A);
    if (!Avalbytes) {
      jsonResp.error = 'Failed to get state for ' + A;
      throw new Error(JSON.stringify(jsonResp));
    }

    jsonResp.name = A;
    jsonResp.amount = Avalbytes.toString();
    console.info('Query Response:');
    console.info(jsonResp);
    return Avalbytes;
  }



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



};

shim.start(new Chaincode());
