package com.example.pos.modules.printer

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.BitmapFactory.Options
import android.util.Base64
import android.util.Log
import com.example.pos.ModuleSupportedFragment
import com.pax.dal.IPrinter
import com.pax.dal.entity.EFontTypeAscii
import com.pax.dal.entity.EFontTypeExtCode
import com.pax.dal.exceptions.PrinterDevException
import java.util.concurrent.*

class PrinterController(appContext: Context) {
    private var printer: IPrinter
    var thread:Thread? = null

    init {
        printer = ModuleSupportedFragment().getDal(appContext)!!.getPrinter()
        Log.d("printer", "printer")
    }

    fun initPrinter() {
        try {
            printer.init()
            Log.d("init", "init")
        } catch (e: PrinterDevException) {
            e.printStackTrace()
            Log.e("init", e.toString())
        }
    }

    val status: String
        get() =
            try {
                val status: Int = printer.getStatus()
                Log.d("getStatus", "$status")
                statusCode2Str(status)
            } catch (e: PrinterDevException) {
                e.printStackTrace()
                Log.e("getStatus", e.toString())
                ""
            }

    fun fontSet(asciiFontType: EFontTypeAscii?, cFontType: EFontTypeExtCode?) {
        try {
            printer.fontSet(asciiFontType, cFontType)
            Log.d("fontSet", "fontSet")
        } catch (e: PrinterDevException) {
            e.printStackTrace()
            Log.e("fontSet", e.toString())
        }
    }

    fun spaceSet(wordSpace: Byte, lineSpace: Byte) {
        try {
            printer.spaceSet(wordSpace, lineSpace)
            Log.d("spaceSet", "spaceSet")
        } catch (e: PrinterDevException) {
            e.printStackTrace()
            Log.e("spaceSet", e.toString())
        }
    }

     fun printStr(str: String?, image: String?) {
        try {
            Log.d("printStr", "$str")
            printer.printStr(str, image)
            Log.d("printStr", "$str")
            if (str != null) {


                val executor = Executors.newSingleThreadExecutor()

                val future: Future<*> = executor.submit {
                    // Your thread logic goes here\
                    var data: String = ""
                    try {
                        val data = start(str,image)
                        println("Production Result: $data") //
//                        if(!thread!!.isAlive() || data.isNotEmpty()) {
//                            System.out.println("*************Is alive?:********" + thread!!.isAlive())
//                            cutInvoice()
//                        }
                        // comment: Use the result in your application logic
                    } catch (e: Exception) {
                        println("Error fetching or processing data: ${e.message}")
                    }

                }

                // Check if the thread is terminated and then execute your function
                while (!future.isDone) {
                    // Do something else while waiting, or simply sleep for a short interval
              Thread.sleep(1000)
                }

                // The thread has terminated, now you can call your function
                onThreadTerminated()

                // Shutdown the executor
                executor.shutdown()
//                if (data != null) {
//                    if (printer == null) initPrinter()
//                  if(!(thread!!.isAlive)) {
//                      Log.d("********* thread!!.isAlive print str **********", "${thread!!.isAlive}")
////                      cutInvoice()
//                      return true
//                  }else return  false
//
//                } else
//                        return false
            }
//           else return  false
        } catch (e: PrinterDevException) {
            e.printStackTrace()
            Log.e("printStr", e.toString())
//            return  false
        }
    }
    fun onThreadTerminated() {
        println("Thread has terminated. Executing onThreadTerminated function.${        (!thread!!.isAlive())
        }")
        cutInvoice()
    }

   fun printBitmapLogo( bitmap:Bitmap) {
        try {
            printer.printBitmap(bitmap);
            Log.d("printBitmap","bitmap")
        } catch (e: PrinterDevException ) {
            e.printStackTrace()
            Log.e("printBitmap", e.toString());
        }
    }

    fun cutInvoice(){
        printer.init()
        printer.cutPaper(1)
    }
    fun step(b: Int) {
        try {
            printer.step(b)
            Log.d("setStep", "setStep")
        } catch (e: PrinterDevException) {
            e.printStackTrace()
            Log.e("setStep", e.toString())
        }
    }



     fun start(printText: String, image: String?): String {
         var res = 0
         thread= Thread {
             printer.init()
             val options = Options()
             options.inScaled = false
             options.inMutable = true
             if(image != null){
                 val decodedString: ByteArray = Base64.decode(image, Base64.DEFAULT)
                 val decodedByte: Bitmap =
                     BitmapFactory.decodeByteArray(decodedString, 0, decodedString.size,options)
                 printBitmapLogo(decodedByte)
             }
//             printer.step(1)


             printer.spaceSet("1".toByte(), "1".toByte())
             printer.leftIndent("1".toShort().toInt())
             printer.setGray("1".toInt())

             var BILL: String = printText
             if (BILL != null && BILL.length > 0) printer.printStr(BILL, null)
             printer.getDotLine().toString() + ""
             res = printer.start()
             Log.d("done", "print $res")
             println("Thread has terminated. Executing onThreadTerminated function.${        (!thread!!.isAlive())
             }")
             cutInvoice()
         }

        return try {
            thread!!.start()
            Log.d("printText Start =========", "$printText")
                statusCode2Str(res)
        } catch (e: PrinterDevException) {
            e.printStackTrace()
            Log.e("start", e.toString())
            ""
        }
    }

    fun leftIndents(indent: Int) {
        try {
            printer.leftIndent(indent)
            Log.d("leftIndent", "leftIndent")
        } catch (e: PrinterDevException) {
            e.printStackTrace()
            Log.e("leftIndent", e.toString())
        }
    }

    val dotLine: Int
        get() {
            return try {
                val dotLine: Int = printer.getDotLine()
                Log.d("getDotLine", "getDotLine")
                dotLine
            } catch (e: PrinterDevException) {
                e.printStackTrace()
                Log.e("getDotLine", e.toString())
                -2
            }
        }

    fun setGray(level: Int) {
        try {
            printer.setGray(level)
            Log.d("setGray", "setGray")
        } catch (e: PrinterDevException) {
            e.printStackTrace()
            Log.e("setGray", e.toString())
        }
    }

    fun setDoubleWidth(isAscDouble: Boolean, isLocalDouble: Boolean) {
        try {
            printer.doubleWidth(isAscDouble, isLocalDouble)
            Log.d("doubleWidth", "doubleWidth")
        } catch (e: PrinterDevException) {
            e.printStackTrace()
            Log.e("doubleWidth", e.toString())
        }
    }

    fun setDoubleHeight(isAscDouble: Boolean, isLocalDouble: Boolean) {
        try {
            printer.doubleHeight(isAscDouble, isLocalDouble)
            Log.d("doubleHeight", "doubleHeight")
        } catch (e: PrinterDevException) {
            e.printStackTrace()
            Log.e("doubleHeight", e.toString())
        }
    }

    fun setInvert(isInvert: Boolean) {
        try {
            printer.invert(isInvert)
            Log.d("setInvert", "setInvert")
        } catch (e: PrinterDevException) {
            e.printStackTrace()
            Log.e("setInvert", e.toString())
        }
    }

    fun cutPaper(mode: Int): String {
        return try {
            printer.cutPaper(mode)
            Log.d("cutPaper", "cut paper successful")
            return  "cut paper successful"

        } catch (e: PrinterDevException) {
            e.printStackTrace()
            Log.e("cutPaper", e.toString())
            e.toString()
        }
    }

    val cutMode: String
        get() {
            var resultStr = ""
            return try {
                val mode: Int = printer.getCutMode()
                Log.d("getCutMode", "getCutMode")
                when (mode) {
                    0 -> resultStr = "Only support full paper cut"
                    1 -> resultStr = "Only support partial paper cutting "
                    2 -> resultStr = "support partial paper and full paper cutting "
                    -1 -> resultStr = "No cutting knife,not support"
                    else -> {}
                }
                resultStr
            } catch (e: PrinterDevException) {
                e.printStackTrace()
                Log.e("getCutMode", e.toString())
                e.toString()
            }
        }

    fun statusCode2Str(status: Int): String {
        var res = ""
        when (status) {
            0 -> res = "Success "
            1 -> res = "Printer is busy "
            2 -> res = "Out of paper "
            3 -> res = "The format of print data packet error "
            4 -> res = "Printer malfunctions "
            8 -> res = "Printer over heats "
            9 -> res = "Printer voltage is too low"
            240 -> res = "Printing is unfinished "
            252 -> res = " The printer has not installed font library "
            254 -> res = "Data package is too long "
            else -> {}
        }
        return res
    }

    //    companion object {
    //        private var printerTester: PrinterController? = null
    //        val instance: PrinterController?
    //            get() {
    //                if (printerTester == null) {
    //                    printerTester = PrinterController(getA)
    //                }
    //                return printerTester
    //            }
    //    }
}
