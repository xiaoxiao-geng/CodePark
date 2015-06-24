package org.cocos2dx.lua;

import java.util.UUID;

import android.bluetooth.BluetoothAdapter;
import android.content.Context;
import android.content.Intent;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.provider.Settings.Secure;
import android.telephony.TelephonyManager;
import org.cocos2dx.lib.Cocos2dxActivity;

public class MyKey {
	
	public static String getKey()
	{
		return getUniqueNumber(Cocos2dxActivity.getContext());//UUID.randomUUID().toString();
	}

	/**
	 * 得到设备<a href="http://www.it165.net/pro/ydad/" target="_blank" class="keylink">Android</a>ID，需要设备添加 Google账户
	 * 
	 * @param context
	 * @return
	 */
	public static String getAndroidID(Context context) {
		String androidID = Secure.getString(context.getContentResolver(),
				Secure.ANDROID_ID);
		return androidID;
	}

	/**
	 * 得到设备IMEI值
	 * 
	 * @param context
	 * @return
	 */
	public static String getIMEI(Context context) {
		TelephonyManager tm = (TelephonyManager) context
				.getSystemService(Context.TELEPHONY_SERVICE);
		return tm.getDeviceId();
	}

	/**
	 * 得到设备序列号
	 * 
	 * @param context
	 * @return
	 */
	public static String getSimSerialNumber(Context context) {
		TelephonyManager tm = (TelephonyManager) context
				.getSystemService(Context.TELEPHONY_SERVICE);
		return tm.getSimSerialNumber();
	}

	/**
	 * 得到设备唯一识别码
	 * 
	 * @param context
	 * @return
	 */
	public static String getUniqueNumber(Context context) {
		String macAddress = getWLANMACAddress(context);
		String imei = getIMEI(context);
		String simSerialNumber = getSimSerialNumber(context);
		long imeiHash = 0;
		long macHash = 0;
		long serialHash = 0;
		try{
			imeiHash = (long)imei.hashCode() << 32;
		}
		catch (Exception e){}
		try{
			macHash = macAddress.hashCode();
		}
		catch(Exception e){}
		try{
			serialHash = simSerialNumber.hashCode();
		}
		catch(Exception e){}
		
		UUID uuid = new UUID(imeiHash, macHash | serialHash);
		return uuid.toString();
	}

	/**
	 * 获取设备本身网卡的MAC地址
	 * 
	 * @param context
	 * @return
	 */
	public static String getWLANMACAddress(Context context) {
		String macAddress = "";
		WifiManager wm = (WifiManager) context
				.getSystemService(Context.WIFI_SERVICE);
		WifiInfo info = wm.getConnectionInfo();
		if (info != null) {
			macAddress = info.getMacAddress();
		} else {
			macAddress = "No Wifi Device";
		}
		return macAddress;
	}

	/**
	 * 获取蓝牙MAC地址
	 * 
	 * @param context
	 * @return
	 */
	public static String getBluetoothMACAddress(Context context) {
		String btMacAddress = "";
		BluetoothAdapter ba = BluetoothAdapter.getDefaultAdapter();
		if (ba != null) {
			if (!ba.isEnabled()) {
				btMacAddress = "Bluetooth not open";
				// 启动蓝牙
				Intent in = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
				context.startActivity(in);
			} else {
				btMacAddress = ba.getAddress();
			}

		} else {
			btMacAddress = "No Bluetooth Device";
		}
		return btMacAddress;
	}
}
