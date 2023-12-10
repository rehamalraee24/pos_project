package com.example.pos
import android.os.Bundle
import com.pax.unifiedsdk.factory.ITransAPI;
import com.pax.unifiedsdk.factory.TransAPIFactory;
import com.pax.unifiedsdk.message.BaseResponse;
import com.pax.unifiedsdk.message.CommConnectMsg;
import com.pax.unifiedsdk.message.PrintBitmapMsg;
import com.pax.unifiedsdk.message.SaleMsg;
import com.pax.unifiedsdk.message.SettleMsg;
import com.pax.unifiedsdk.message.TransResponse;
import com.pax.unifiedsdk.sdkconstants.SdkConstants;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.dart.DartExecutor;

class MainActivity : FlutterActivity() {
     private val CHANNEL = "aumet.pos"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Set up the MethodChannel with the same name as defined in Dart
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getDataFromNative") {
                val amount: String? =  call.argument("amount")

                // Perform platform-specific operations and obtain the result
                val data = startSale(amount)

                // Send the result back to Flutter
                result.success(data)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun startSale( amount: String?): String {
        val transAPI: ITransAPI = TransAPIFactory.createTransAPI();

        val requestConnection :CommConnectMsg.Request=  CommConnectMsg.Request();
        requestConnection.setCommType(CommConnectMsg.Request.USB);
        requestConnection.setCategory(SdkConstants.CATEGORY_COMM_CONNECT);
        requestConnection.setDefault(true);
        transAPI.startTrans(this, requestConnection);
        val request :SaleMsg.Request =  SaleMsg.Request();
        request.setCategory(SdkConstants.CATEGORY_SALE)
        request.setAmount(amount.toString().toLong())
        request.setTipAmount(0)
        val bundle = Bundle()
        bundle.putString("tranNumber", "10")
        request.setExtraBundle(bundle)
        transAPI.startTrans(activity, request)
        return "$amount"
    }

}