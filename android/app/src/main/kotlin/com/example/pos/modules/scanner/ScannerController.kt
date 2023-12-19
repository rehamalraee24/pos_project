
package com.aumet.pos

import com.pax.dal.IScanner
import com.pax.dal.IScanner.IScanListener
import com.pax.dal.entity.EScannerType
import com.pax.dal.entity.ScanResult
import android.os.Handler;
import android.content.Context
import android.util.Log
import android.widget.Toast
import com.pax.dal.IDAL
import com.pax.neptunelite.api.NeptuneLiteUser
import com.aumet.pos.MainActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class Scanner  {
    private val CHANNEL = MainActivity().CHANNEL
    private var scanner: IScanner?=null
    private  val scannerType :EScannerType= EScannerType.REAR
    private var dal: IDAL? = null
    private var barcode: String =""
   fun initScanner (appContext : Context,flutterEngine: FlutterEngine){
        Log.d("scannerType",scannerType.toString())
        scanner = getDal(appContext)!!.getScanner(scannerType)
       if(scanner == null)  Log.i("null","Scanner")
         scan(flutterEngine)
       Log.d("barcode----------","$barcode")

    }
    private fun getDal(context :Context): IDAL? {
        if (dal == null) {
            try {
                val start = System.currentTimeMillis()
                dal = NeptuneLiteUser.getInstance().getDal(context)
                Log.i("Test", "get dal cost:" + (System.currentTimeMillis() - start) + " ms")
            } catch (e: Exception) {
                e.printStackTrace()
                Toast.makeText(context, "error occurred,DAL is null.", Toast.LENGTH_LONG).show()
            }
        }
        return dal
    }
    fun scan(flutterEngine: FlutterEngine) {
        if(scanner == null)  Log.i("nul2l","Scanner")
        scanner!!.open()
        Log.d("open","opened")
        scanner!!.setContinuousTimes(1)
        scanner!!.setContinuousInterval(1000)
        scanner!!.start( object : IScanListener {
            override
            fun onRead(result: ScanResult) {
                val message: android.os.Message = android.os.Message.obtain()
                message.what = 0
                message.obj = result.getContent()
                val msg = message
                barcode = msg.obj.toString()
                Log.d("read:" , "$barcode")
//                handler.sendMessage(message)
            }
            override
            fun onFinish() {
                Log.d("onFinish","finished")
                Log.d("FINISH:" , "$barcode")
                close(flutterEngine)
            }
            override
            fun onCancel() {
                Log.d("onCancel","canceled")
                Log.d("CANCEL:" , "$barcode")
                close(flutterEngine)
            }
        })
        Log.d("barcode","$barcode")

    }

    fun close(flutterEngine : FlutterEngine) {
        scanner!!.close()
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("barcodeReader","$barcode")
        Log.d("close","closed")
        Log.d("close--------------","$barcode")
    }

    fun setTimeOut(timeout: Int) {
        scanner!!.setTimeOut(timeout)
        Log.d("setTimeOut","our")
    }

    fun setFlashOn(isOn: Boolean): Boolean {
        val result: Boolean = scanner!!.setFlashOn(isOn)
        if (result) {
            Log.d("setFlashOn","flash")
        } else {
            Log.d("setFlashOn", "set flash on failed")
        }
        return result
    }

//    fun setScannerType(type: Int): Boolean {
//        val result: Boolean = scanner!!.setScannerType(type)
//        if (result) {
//            Log("setScannerType")
//        } else {
//            logErr("setScannerType", "set scanner type failed")
//        }
//        return result
//    }
//
//    companion object {
//        private var cameraTester: ScannerTester? = null
//        private var scannerType: EScannerType? = null
//        fun getInstance(type: EScannerType): ScannerTester? {
//            if (cameraTester == null || type !== scannerType) {
//                cameraTester = ScannerTester(type)
//            }
//            return cameraTester
//        }
//    }
    private val handler: Handler = object : Handler() {
        override
        fun handleMessage(msg: android.os.Message) {
            when (msg.what) {
                0 -> {
                    Log.d("barcodeScannerDone", msg.obj.toString())
                    barcode = msg.obj.toString()
                }
                else -> {
                    barcode = ""
                }
            }
        }
    }
}