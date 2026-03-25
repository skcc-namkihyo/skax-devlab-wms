package com.execnt.wms.mapper;

import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

@Mapper
public interface StatusChangeHistoryMapper {

    List<Map<String, Object>> selectStatusChangeHistoryList(Map<String, Object> params);

    int countStatusChangeHistoryList(Map<String, Object> params);
}
