package com.execnt.wms.service;

import com.execnt.wms.mapper.StatusChangeHistoryMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** {@code wms.status_change_history} 페이징 조회 */
@Service
public class StatusChangeHistoryService {

    private final StatusChangeHistoryMapper statusChangeHistoryMapper;

    public StatusChangeHistoryService(StatusChangeHistoryMapper statusChangeHistoryMapper) {
        this.statusChangeHistoryMapper = statusChangeHistoryMapper;
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
        List<Map<String, Object>> list = statusChangeHistoryMapper.selectStatusChangeHistoryList(params);
        int total = statusChangeHistoryMapper.countStatusChangeHistoryList(params);
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
