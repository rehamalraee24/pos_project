package com.aumet.pos
import android.content.Context
import android.util.Log
import android.widget.Toast
import com.pax.dal.IDAL
import com.pax.dal.IDeviceInfo
import com.pax.dal.IDeviceInfo.ESupported
import com.pax.neptunelite.api.NeptuneLiteUser

public class ModuleSupportedFragment{
    private var deviceInfo: IDeviceInfo? =  null
    private var dal: IDAL? = null
    private var appContext: Context?= null


    public fun getScannerType ( context:Context): String {
        appContext =context
        deviceInfo=getDal(context)!!.getDeviceInfo()
        val moduleSupported: Map<Int, ESupported> = deviceInfo!!.getModuleSupported()
        val scannerType = moduleSupported.get(IDeviceInfo.MODULE_SCANNER_HW).toString()
        Log.d("scanner",scannerType)
        ///if == "NO" regular else hardware
        return  scannerType
    }

    fun getDal(context:Context?): IDAL? {
        if (dal == null) {
            try {
                val start = System.currentTimeMillis()
                dal = NeptuneLiteUser.getInstance().getDal(if(context == null)  appContext else context)
                Log.i("Test", "get dal cost:" + (System.currentTimeMillis() - start) + " ms")
            } catch (e: Exception) {
                e.printStackTrace()
                Toast.makeText(appContext, "error occurred,DAL is null.", Toast.LENGTH_LONG).show()
            }
        }
        return dal
    }
}