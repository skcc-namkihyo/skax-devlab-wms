package com.execnt.wms.service;

import com.execnt.wms.mapper.ScreenAccessLogMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** {@code wms.screen_access_log} 페이징 조회 */
@Service
public class ScreenAccessLogService {

    private final ScreenAccessLogMapper screenAccessLogMapper;

    public ScreenAccessLogService(ScreenAccessLogMapper screenAccessLogMapper) {
        this.screenAccessLogMapper = screenAccessLogMapper;
    }

    /**
     * @param query {@code page}(기본 1), {@code pageSize}(기본 20)
     * @return {@code list}, {@code total}, {@code page}, {@code pageSize}
     */
    public Map<String, Object> findList(Map<String, Object> query) throws Exception {
        int page = parsePositiveInt(query.get("page"), 1);
        int pageSize = parsePositiveInt(query.get("pageSize"), 20);
        int offset = (page - 1) * pageSize;
        Map<String, Object> params = new HashMap<>();
        params.put("limit", pageSize);
        params.put("offset", offset);
        List<Map<String, Object>> list = screenAccessLogMapper.selectScreenAccessLogList(params);
        int total = screenAccessLogMapper.countScreenAccessLogList(params);
        Map<String, Object> data = new HashMap<>();
        data.put("list", list);
        data.put("total", total);
        data.put("page", page);
        data.put("pageSize", pageSize);
        return data;
    }

    private static int parsePositiveInt(Object raw, int defaultVal) {
        if (raw == null) {
            return defaultVal;
        }
        try {
            int n = Integer.parseInt(raw.toString().trim());
            return n > 0 ? n : defaultVal;
        } catch (NumberFormatException e) {
            return defaultVal;
        }
    }
}
