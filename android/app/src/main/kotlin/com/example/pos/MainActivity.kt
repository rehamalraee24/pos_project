package com.aumet.pos
import android.app.Activity.RESULT_OK
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import com.aumet.pos.modules.printer.PrinterController
import com.pax.unifiedsdk.factory.ITransAPI
import com.pax.unifiedsdk.factory.TransAPIFactory
import com.pax.unifiedsdk.message.BaseResponse
import com.pax.unifiedsdk.message.CommConnectMsg
import com.pax.unifiedsdk.message.PrintBitmapMsg
import com.pax.unifiedsdk.message.SaleMsg
import com.pax.unifiedsdk.message.TransResponse
import com.pax.unifiedsdk.sdkconstants.SdkConstants
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
class MainActivity : FlutterActivity() {
    val CHANNEL = "aumet.pos"
    var transAPI: ITransAPI? = null
    var isPrint: Boolean = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call,
                result ->
            if (call.method.equals("loadArchFiles")) {
                loadArchFiles()
                result.success(null)
            } else if (call.method == "sale") {
                transAPI = TransAPIFactory.createTransAPI()
                val requestConnection: CommConnectMsg.Request = CommConnectMsg.Request()
                requestConnection.setCommType(CommConnectMsg.Request.USB)
                requestConnection.setCategory(SdkConstants.CATEGORY_COMM_CONNECT)
                requestConnection.setDefault(true)
                transAPI!!.startTrans(this, requestConnection)
                val amount: String? = call.argument("amount")
                val data = startSale(amount)
                // Send the result back to Flutter
                //                result.success(data)
            } else if (call.method == "scan") {
                val doesSupportScannerHw =
                    ModuleSupportedFragment().getScannerType(getApplicationContext())
                Log.d("doesSupportScannerHw", doesSupportScannerHw)

                val barcode = Scanner().initScanner(getApplicationContext(), flutterEngine)
                //              Log.doesSupportScannerHw("barcode","$barcode")
                //              result.success(barcode)
            } else if (call.method == "print") {
                val printString: String = (call.argument("printString"))!!
                val image: String? = (call.argument("image"))
                //              PrinterController().initPrinter()
  //                printAPi(printString)
                    PrinterController(getApplicationContext()).printStr(printString,image)
//                    if(!(PrinterController(getApplicationContext()).thread!!.isAlive)) {
//                        Log.d("********* thread!!.isAlive print str **********", "${PrinterController(getApplicationContext()).thread!!.isAlive}")
//                        PrinterController(getApplicationContext()).cutInvoice()
//                        result.success(true)
//                    }

            } else if(call.method == "cut"){
                val cut=  PrinterController(getApplicationContext()).cutInvoice()
                Log.d("print", "$cut")
            }else {
                result.notImplemented()
            }
        }
    }

    private fun startSale(amount: String?) {
        isPrint = false

        val request: SaleMsg.Request = SaleMsg.Request()
        request.setCategory(SdkConstants.CATEGORY_SALE)
        request.setAmount(amount.toString().toLong())
        request.setTipAmount(0)
        val bundle = Bundle()
        bundle.putString("tranNumber", "10")
        request.setExtraBundle(bundle)
        transAPI!!.startTrans(activity, request)
    }

    private fun printAPi(imgStr: String) {
        isPrint = true
        transAPI = TransAPIFactory.createTransAPI()
        val printBitmapRequest: PrintBitmapMsg.Request = PrintBitmapMsg.Request()
        printBitmapRequest.setBitmap(imgStr)
        printBitmapRequest.setCategory(SdkConstants.CATEGORY_PRINT_BITMAP)
        transAPI!!.startTrans(this, printBitmapRequest)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        val baseResponse: BaseResponse =
            transAPI!!.onResult(requestCode, resultCode, data) ?: return
        // when you didn't chose any one
        val isTransResponse = baseResponse is TransResponse
        if (isTransResponse) {
            val response: TransResponse = baseResponse as TransResponse
            Log.d("response", response.getTvr())
            Log.d("response", response.getAid())
            Toast.makeText(this, response.getRspMsg(), Toast.LENGTH_LONG).show()
//            val bundle = Bundle()
//            bundle.putString("Aid", "${response.getAid()}")
//            bundle.putString("Tvr", "${response.getTvr()}")
//            response.setExtraBundle(bundle)
//            Log.d("bundle", bundle.toString())
//            Log.d("response.getRspMsg().toString()", response.toString())
            setResult(RESULT_OK, data)
              if (isPrint == false)
                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                    .invokeMethod("result", "${response.toString()}")
        } else {
            Toast.makeText(this, baseResponse.getRspMsg(), Toast.LENGTH_LONG).show()
            Log.d("baseResponse", baseResponse.getRspMsg())
            setResult(RESULT_CANCELED, data)
            if (isPrint == false)
                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                    .invokeMethod("result", "${baseResponse.toString()}")
        }
    }

    private fun loadArchFiles() {
        Log.d("**********loadArchFiles", "arch")

        // Get the device's architecture
        val arch = System.getProperty("os.arch")
        Log.d("**********loadArchFiles***********", "$arch")

        // "armeabi", "x86", "armeabi-v7a", "arm64-v8a", "x86_64"
        // Load architecture-specific files dynamically
        if (arch == "arm") {
            System.loadLibrary("arm")
            Log.d("arm", "arm")
        } else if (arch == "arm64") {
            System.loadLibrary("arm64")
            Log.d("arm64", "arm64")
        } else if (arch == "x86") {
            System.loadLibrary("x86")
            Log.d("x86", "x86")
        } else if (arch == "x86_64") {
            Log.d("x86_64", "x86_64")

            System.loadLibrary("flutter")
            System.loadLibrary("DeviceConfig")
        }
    }
}
