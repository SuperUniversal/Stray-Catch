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
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;

public class MainActivity extends AppCompatActivity {

    private static final String TAG = "A1_231A290021";
    private static final String[] CALLBACKS = {
            "onCreate",
            "onStart",
            "onResume",
            "onPause",
            "onStop",
            "onRestart",
            "onDestroy",
            "onSaveInstanceState"
    };

    private TextView tvLog;
    private TextView tvCounts;
    private final StringBuilder history = new StringBuilder();
    private final LinkedHashMap<String, Integer> counts = new LinkedHashMap<>();
    private int step = 0;

    /** Ghi một sự kiện ra Logcat, màn hình và bảng đếm (NC1). */
    private void logEvent(String event) {
        step++;
        String time = new SimpleDateFormat("HH:mm:ss.SSS", Locale.getDefault())
                .format(new Date());
        String line = step + ". [" + time + "] " + event;
        Log.d(TAG, line);
        history.append(line).append('\n');
        if (tvLog != null) {
            tvLog.setText(history.toString());
        }
        bumpCount(callbackName(event));
    }

    private void resetCounts() {
        counts.clear();
        for (String name : CALLBACKS) {
            counts.put(name, 0);
        }
        renderCounts();
    }

    private void bumpCount(String name) {
        counts.put(name, counts.getOrDefault(name, 0) + 1);
        renderCounts();
    }

    private void renderCounts() {
        if (tvCounts == null) {
            return;
        }
        StringBuilder table = new StringBuilder();
        for (Map.Entry<String, Integer> entry : counts.entrySet()) {
            if (table.length() > 0) {
                table.append('\n');
            }
            table.append(entry.getKey()).append(": ").append(entry.getValue());
        }
        tvCounts.setText(table.toString());
    }

    private static String callbackName(String event) {
        int space = event.indexOf(' ');
        return space < 0 ? event : event.substring(0, space);
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
        tvCounts = findViewById(R.id.tvCounts);
        resetCounts();

        Button btnClear = findViewById(R.id.btnClear);
        Button btnCrash = findViewById(R.id.btnCrash);
        Button btnFinish = findViewById(R.id.btnFinish);

        btnClear.setOnClickListener(v -> {
            history.setLength(0);
            step = 0;
            tvLog.setText("");
            resetCounts();
            Log.i(TAG, "---- Đã xóa lịch sử ----");
        });

        // NC2: bắt NullPointerException, không để app crash.
        btnCrash.setOnClickListener(v -> {
            try {
                String ten = null;
                Log.d(TAG, "Độ dài tên: " + ten.length());
            } catch (NullPointerException e) {
                Log.e(TAG, "Bắt được lỗi NullPointerException", e);
                Toast.makeText(this, R.string.caught_null, Toast.LENGTH_SHORT).show();
            }
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
