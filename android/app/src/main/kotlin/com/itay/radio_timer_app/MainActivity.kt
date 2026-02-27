package com.itay.radio_timer_app

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Enable edge-to-edge BEFORE Flutter initializes so it inherits the
        // window flags and avoids the deprecated setStatusBarColor /
        // setNavigationBarColor APIs (Android 15+).
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
    }
}
