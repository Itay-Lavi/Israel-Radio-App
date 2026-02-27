package com.itay.radio_timer_app

import android.os.Build
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onPostResume() {
        super.onPostResume()
        
        // Enable edge-to-edge display for Android 15+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            WindowCompat.setDecorFitsSystemWindows(window, false)
        }
    }
}
