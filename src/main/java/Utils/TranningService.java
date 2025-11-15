package Utils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

import com.fasterxml.jackson.databind.ObjectMapper;


public class TranningService {
    public static Map<String,Object> callTrainingService(int modelId, int datasetId, String weight) throws IOException {
        String apiUrl = "http://127.0.0.1:8000/api/retrain_detect";

        String safeWeight = weight.replace("\\", "\\\\").replace("\"", "\\\"");

        String jsonPayload = String.format(
                "{\"model_id\":%d,\"dataset_id\":%d,\"weights\":\"%s\"}",
                modelId, datasetId, safeWeight
        );

        URL url = new URL(apiUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setConnectTimeout(60_000);// thời  gian chờ thiết lập tcp
        conn.setReadTimeout(600_000);// thời gian chờ dl từ server từ khi kn
        conn.setDoOutput(true);// để gửi body
        conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
//      gửi body
        try (OutputStream os = conn.getOutputStream()) {
            os.write(jsonPayload.getBytes(StandardCharsets.UTF_8));
            os.flush();
        }
//nhận status code
        int status = conn.getResponseCode();
        InputStream is = (status >= 200 && status < 300) ? conn.getInputStream() : conn.getErrorStream();

        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) sb.append(line);
        } finally {
            conn.disconnect();
        }
        String body = sb.toString();
// nhận kết quả
        Map<String, Object> result = new HashMap<>();
        result.put("http_status", status);
        result.put("raw", body);
// parse json thành map
        try {
            ObjectMapper om = new ObjectMapper();
            @SuppressWarnings("unchecked")
            Map<String,Object> parsed = om.readValue(body, Map.class);
            if (parsed != null) result.putAll(parsed);
        } catch (Throwable t) {
            java.util.regex.Matcher m = java.util.regex.Pattern.compile("\"job_id\"\\s*:\\s*\"([^\"]+)\"").matcher(body);
            if (m.find()) result.put("job_id", m.group(1));
        }
        return result;
    }
}
