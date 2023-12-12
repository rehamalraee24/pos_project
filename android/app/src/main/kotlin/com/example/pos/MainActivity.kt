package com.example.pos

import android.app.Activity.RESULT_OK
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import com.pax.unifiedsdk.factory.ITransAPI
import com.pax.unifiedsdk.factory.TransAPIFactory
import com.pax.unifiedsdk.message.BaseResponse
import com.pax.unifiedsdk.message.CommConnectMsg
import com.pax.unifiedsdk.message.SaleMsg
import com.pax.unifiedsdk.message.TransResponse
import com.pax.unifiedsdk.sdkconstants.SdkConstants
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "aumet.pos"
    // var trans
    var transAPI: ITransAPI? = null

    override protected fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        transAPI = TransAPIFactory.createTransAPI()
        val requestConnection: CommConnectMsg.Request = CommConnectMsg.Request()
        requestConnection.setCommType(CommConnectMsg.Request.USB)
        requestConnection.setCategory(SdkConstants.CATEGORY_COMM_CONNECT)
        requestConnection.setDefault(true)
        transAPI!!.startTrans(this, requestConnection)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Set up the MethodChannel with the same name as defined in Dart
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call,
                result ->
            if (call.method == "sale") {
                val amount: String? = call.argument("amount")

                // Perform platform-specific operations and obtain the result
                val data = startSale(amount)

                // Send the result back to Flutter
//                result.success(data)
            } else if (call.method == "scan") {
                val data = startScan()
            } else {
                result.notImplemented()
            }
        }
    }

    private fun startSale(amount: String?) {
        val transAPI: ITransAPI = TransAPIFactory.createTransAPI()

        val requestConnection: CommConnectMsg.Request = CommConnectMsg.Request()
        requestConnection.setCommType(CommConnectMsg.Request.USB)
        requestConnection.setCategory(SdkConstants.CATEGORY_COMM_CONNECT)
        requestConnection.setDefault(true)
        transAPI.startTrans(this, requestConnection)
        val request: SaleMsg.Request = SaleMsg.Request()
        request.setCategory(SdkConstants.CATEGORY_SALE)
        request.setAmount(amount.toString().toLong())
        request.setTipAmount(0)
        val bundle = Bundle()
        bundle.putString("tranNumber", "10")
        request.setExtraBundle(bundle)
        transAPI.startTrans(activity, request)
    }

    private fun startScan(): String {
        val transAPI: ITransAPI = TransAPIFactory.createTransAPI()

        val requestConnection: CommConnectMsg.Request = CommConnectMsg.Request()
        requestConnection.setCommType(CommConnectMsg.Request.USB)
        requestConnection.setCategory(SdkConstants.CATEGORY_COMM_CONNECT)
        requestConnection.setDefault(true)
        transAPI.startTrans(this, requestConnection)
        val request: SaleMsg.Request = SaleMsg.Request()
        request.setCategory(SdkConstants.CATEGORY_SALE)
        request.setAmount("".toLong())
        request.setTipAmount(0)
        val bundle = Bundle()
        bundle.putString("tranNumber", "10")
        request.setExtraBundle(bundle)
        transAPI.startTrans(activity, request)
        return ""
        /// Todo:: return barcode
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        val baseResponse: BaseResponse =
            transAPI!!.onResult(requestCode, resultCode, data) ?: return
        // when you didn't chose any one
        val isTransResponse = baseResponse is TransResponse
        if (isTransResponse) {
            val response: TransResponse = baseResponse as TransResponse
            //            Bundle bundle = response.getExtraBundle();
            //            bundle.getString("trans_number");
            Log.d("response", response.toString())
            Toast.makeText(this, response.getRspMsg(), Toast.LENGTH_LONG).show()
            setResult(RESULT_OK, data)
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("result","${response.toString()}")

        } else {
            Toast.makeText(this, baseResponse.getRspMsg(), Toast.LENGTH_LONG).show()
            Log.d("baseResponse", baseResponse.getRspMsg())

            setResult(RESULT_CANCELED, data)
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("result","${baseResponse.getRspMsg().toString()}")

        }
    }
}
