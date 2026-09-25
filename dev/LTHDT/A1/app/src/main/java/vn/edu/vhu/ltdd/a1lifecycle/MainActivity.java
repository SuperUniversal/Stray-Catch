package vn.edu.vhu.ltdd.a1lifecycle;

import android.os.Bundle;
import android.util.Log;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class MainActivity extends AppCompatActivity {

    private static final String TAG = "A1_231A290021";

    private TextView tvLog;
    private final StringBuilder history = new StringBuilder();
    private int step = 0;

    /** Ghi một sự kiện ra Logcat và hiển thị lên màn hình. */
    private void logEvent(String event) {
        step++;
        String time = new SimpleDateFormat("HH:mm:ss.SSS", Locale.getDefault())
                .format(new Date());
        String line = step + ". [" + time + "] " + event;
        Log.d(TAG, line);
        history.append(line).append('\n');
        if (tvLog != null) {
            tvLog.setText(history);
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_main);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        tvLog = findViewById(R.id.tvLog);
        Button btnClear = findViewById(R.id.btnClear);
        Button btnCrash = findViewById(R.id.btnCrash);
        Button btnFinish = findViewById(R.id.btnFinish);

        btnClear.setOnClickListener(v -> {
            history.setLength(0);
            step = 0;
            tvLog.setText("");
            Log.i(TAG, "---- Đã xóa lịch sử ----");
        });

        // Nút cố ý gây lỗi để luyện đọc stack trace trong Logcat
        btnCrash.setOnClickListener(v -> {
            String ten = null;
            Log.d(TAG, "Độ dài tên: " + ten.length()); // NullPointerException
        });

        // finish() để quan sát onDestroy (Android 12+: Back không hủy Activity gốc)
        btnFinish.setOnClickListener(v -> finish());

        String state = (savedInstanceState == null) ? "= null" : "!= null";
        logEvent("onCreate (savedInstanceState " + state + ")");
    }

    @Override
    protected void onStart() {
        super.onStart();
        logEvent("onStart");
    }

    @Override
    protected void onResume() {
        super.onResume();
        logEvent("onResume");
    }

    @Override
    protected void onPause() {
        super.onPause();
        logEvent("onPause");
    }

    @Override
    protected void onStop() {
        super.onStop();
        logEvent("onStop");
    }

    @Override
    protected void onRestart() {
        super.onRestart();
        logEvent("onRestart");
    }

    @Override
    protected void onDestroy() {
        logEvent("onDestroy");
        super.onDestroy();
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        logEvent("onSaveInstanceState");
    }
}
