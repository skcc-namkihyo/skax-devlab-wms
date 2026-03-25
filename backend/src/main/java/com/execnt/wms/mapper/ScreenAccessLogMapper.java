package com.execnt.wms.mapper;

import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

@Mapper
public interface ScreenAccessLogMapper {

    List<Map<String, Object>> selectScreenAccessLogList(Map<String, Object> params);

    int countScreenAccessLogList(Map<String, Object> params);
}
