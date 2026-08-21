package vn.kairo.kaicall

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    // Vuốt app khỏi recents: Android KHÔNG giết tiến trình ngay, và Flutter
    // cũng không giao `detached` xuống Dart — đo trên Honor ELA-LX2 và
    // emulator ngày 2026-08-21: tiến trình vẫn sống, vẫn giữ mic/cam, vẫn nằm
    // trong phòng LiveKit. Đầu kia ngồi nhìn khung hình chết, 90 giây vẫn
    // chưa thoát (CHECKLIST ca 16).
    //
    // Thoát hẳn thì phải đứt hẳn. Đóng tiến trình để socket tới LiveKit đóng
    // theo; đầu kia phát hiện trong 12-15 giây — đúng hàng rào đã chốt ở
    // LiveKitCallSession, không phải một con số mới.
    //
    // `isFinishing` là hàng rào: onDestroy còn chạy ở những lần dựng lại
    // Activity không phải do người dùng thoát, giết tiến trình ở đó là phá.
    override fun onDestroy() {
        val leavingForGood = isFinishing
        super.onDestroy()
        if (leavingForGood) {
            android.os.Process.killProcess(android.os.Process.myPid())
        }
    }
}
