package Utils;

import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.TreeMap;

public class Convert {
    public static String formatDoubleString(Double value) {
        if (value == null) return null;
        return String.format(Locale.US, "%.2f", value);
    }

    public static String formatDateToString(Date date) {
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        return sdf.format(date);
    }

    private static double parsePercentNumber(Object o) {
        if (o == null) return Double.NaN;
        if (o instanceof Number) return ((Number) o).doubleValue(); // already percent (e.g. 99.95)
        String s = o.toString().trim();
        if (s.isEmpty()) return Double.NaN;
        // remove trailing % if present
        if (s.endsWith("%")) s = s.substring(0, s.length()-1).trim();
        s = s.replace(",", "");
        try {
            return Double.parseDouble(s);
        } catch (NumberFormatException ex) {
            return Double.NaN;
        }
    }

    public static Map<String, Double> extractMetrics(Map<String, Object> svcResp){
        Map<String, Double> out = new HashMap<>();
        Object mObj = svcResp.get("metrics");
        if (mObj instanceof Map) {
            Map<String, Object> m = (Map<String, Object>) mObj;
            out.put("precision", parsePercentNumber(m.get("precision")));
            out.put("recall",    parsePercentNumber(m.get("recall")));
            out.put("f1",        parsePercentNumber(m.get("f1")));
            out.put("accuracy",  parsePercentNumber(m.get("accuracy")));
        }
        return out;
    }

    public static String getWeightsFromSvcResp(Map<String, Object> svcResp) {
        if (svcResp == null) return null;

        Object w = svcResp.get("weights");
        if (w != null) {
            return String.valueOf(w);
        }
        return null;
    }
}
