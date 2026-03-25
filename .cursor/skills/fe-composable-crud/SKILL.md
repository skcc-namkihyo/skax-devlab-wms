---
description: "useCrud, useSearch, useTable Composables | CRUD composable utilities"
---

# fe-composable-crud

## 개요

CRUD 작업을 위한 3개 핵심 Composable을 제공합니다. useCrud (데이터 조회/생성/수정/삭제), useSearch (검색/필터링), useTable (테이블 상태 관리)을 포함합니다.

**사용 시점**: 목록 페이지, 편집 페이지에서 데이터 관리가 필요할 때

## 템플릿 / 패턴

### useCrud (CRUD 통합)

```javascript
// composables/useCrud.js
import { useApi } from './useApi.js';

export const useCrud = (apiPath) => {
    const { request, loading } = useApi();
    const list = Vue.ref([]);
    const total = Vue.ref(0);
    const currentItem = Vue.ref(null);

    const pagination = Vue.reactive({
        page: 1,
        limit: 10,
        total: 0
    });

    /**
     * 목록 조회
     * @param {object} params 검색 조건
     * @returns {Promise}
     */
    const fetchList = async (params = {}) => {
        try {
            const response = await request('get', `${apiPath}/list`, {
                page: pagination.page,
                limit: pagination.limit,
                ...params
            });
            list.value = response.data || [];
            total.value = response.total || 0;
            pagination.total = response.total || 0;
        } catch (error) {
            // 에러는 useApi에서 처리
        }
    };

    /**
     * 상세 조회
     * @param {number} id 항목 ID
     * @returns {Promise} 항목 정보
     */
    const fetchById = async (id) => {
        try {
            const response = await request('get', `${apiPath}/${id}`);
            currentItem.value = response;
            return response;
        } catch (error) {
            throw error;
        }
    };

    /**
     * 생성
     * @param {object} item 새 항목 데이터
     * @returns {Promise}
     */
    const create = async (item) => {
        try {
            const response = await request('post', apiPath, item);
            ElMessage.success('생성되었습니다.');
            await fetchList();
            return response;
        } catch (error) {
            throw error;
        }
    };

    /**
     * 수정
     * @param {number} id 항목 ID
     * @param {object} item 수정할 데이터
     * @returns {Promise}
     */
    const update = async (id, item) => {
        try {
            const response = await request('put', `${apiPath}/${id}`, item);
            ElMessage.success('수정되었습니다.');
            await fetchList();
            return response;
        } catch (error) {
            throw error;
        }
    };

    /**
     * 삭제
     * @param {number} id 항목 ID
     * @returns {Promise}
     */
    const deleteItem = async (id) => {
        try {
            await request('delete', `${apiPath}/${id}`);
            ElMessage.success('삭제되었습니다.');
            await fetchList();
        } catch (error) {
            throw error;
        }
    };

    /**
     * 일괄 삭제
     * @param {array} ids 삭제할 항목 ID 목록
     * @returns {Promise}
     */
    const batchDelete = async (ids) => {
        try {
            await request('delete', `${apiPath}/batch`, { ids });
            ElMessage.success('삭제되었습니다.');
            await fetchList();
        } catch (error) {
            throw error;
        }
    };

    return {
        list,
        total,
        currentItem,
        pagination,
        loading,
        fetchList,
        fetchById,
        create,
        update,
        deleteItem,
        batchDelete
    };
};
```

**사용 예시**:
```javascript
setup() {
    const { list, total, pagination, loading, fetchList, create, update, deleteItem } = useCrud('/user');

    const handleSearch = async (filters) => {
        await fetchList(filters);
    };

    const handleCreate = async (formData) => {
        await create(formData);
    };

    return { list, total, pagination, loading, handleSearch, handleCreate, deleteItem };
}
```

### useSearch (검색/필터링)

```javascript
// composables/useSearch.js
export const useSearch = (initialFilters = {}) => {
    const filters = Vue.reactive({...initialFilters});

    /**
     * 필터 적용 여부
     */
    const hasFilters = Vue.computed(() => {
        return Object.values(filters).some(v => v !== null && v !== '' && v !== undefined);
    });

    /**
     * 필터 초기화
     */
    const clearFilters = () => {
        Object.keys(filters).forEach(key => {
            filters[key] = initialFilters[key] || '';
        });
    };

    /**
     * 특정 필터 업데이트
     * @param {string} key 필터 키
     * @param {*} value 필터 값
     */
    const updateFilter = (key, value) => {
        filters[key] = value;
    };

    /**
     * 모든 필터 업데이트
     * @param {object} newFilters 새 필터 객체
     */
    const setFilters = (newFilters) => {
        Object.assign(filters, newFilters);
    };

    return {
        filters,
        hasFilters,
        clearFilters,
        updateFilter,
        setFilters
    };
};
```

**사용 예시**:
```javascript
setup() {
    const { filters, hasFilters, clearFilters } = useSearch({
        userName: '',
        userEmail: '',
        isActive: null
    });

    const handleSearch = async () => {
        await fetchList(filters);
    };

    return { filters, hasFilters, clearFilters, handleSearch };
}
```

### useTable (테이블 상태 관리)

```javascript
// composables/useTable.js
export const useTable = (data = []) => {
    const selectedRows = Vue.ref([]);
    const sortBy = Vue.ref('');
    const sortOrder = Vue.ref('ascending');

    /**
     * 선택된 항목 ID 목록
     */
    const selectedIds = Vue.computed(() => {
        return selectedRows.value.map(row => row.id);
    });

    /**
     * 선택 여부
     */
    const hasSelection = Vue.computed(() => {
        return selectedRows.value.length > 0;
    });

    /**
     * 선택된 항목 개수
     */
    const selectionCount = Vue.computed(() => {
        return selectedRows.value.length;
    });

    /**
     * 선택 변경 처리
     * @param {array} selection 선택된 행 배열
     */
    const handleSelectionChange = (selection) => {
        selectedRows.value = selection;
    };

    /**
     * 정렬 처리
     * @param {string} column 정렬 컬럼
     */
    const handleSort = (column) => {
        if (sortBy.value === column) {
            sortOrder.value = sortOrder.value === 'ascending' ? 'descending' : 'ascending';
        } else {
            sortBy.value = column;
            sortOrder.value = 'ascending';
        }
    };

    /**
     * 모든 행 선택
     */
    const selectAll = () => {
        selectedRows.value = [...data];
    };

    /**
     * 선택 해제
     */
    const clearSelection = () => {
        selectedRows.value = [];
    };

    return {
        selectedRows,
        selectedIds,
        hasSelection,
        selectionCount,
        sortBy,
        sortOrder,
        handleSelectionChange,
        handleSort,
        selectAll,
        clearSelection
    };
};
```

**사용 예시**:
```javascript
setup() {
    const { selectedRows, selectedIds, hasSelection, handleSelectionChange } = useTable(list.value);

    const handleBatchDelete = async () => {
        if (!hasSelection.value) {
            ElMessage.warning('선택한 항목이 없습니다.');
            return;
        }
        await batchDelete(selectedIds.value);
    };

    return { selectedRows, hasSelection, handleSelectionChange, handleBatchDelete };
}
```

## 통합 예시 (List 페이지)

```javascript
export default defineComponent({
    name: 'UserList',
    setup() {
        // CRUD 기능
        const { list, pagination, loading, fetchList, deleteItem, batchDelete } = useCrud('/user');

        // 검색 기능
        const { filters, hasFilters, clearFilters } = useSearch({
            userName: '',
            isActive: null
        });

        // 테이블 상태
        const { selectedRows, hasSelection, handleSelectionChange } = useTable(list.value);

        // 검색 처리
        const handleSearch = async () => {
            pagination.page = 1;
            await fetchList(filters);
        };

        // 페이지 변경
        const handlePageChange = async () => {
            await fetchList(filters);
        };

        // 초기 로드
        Vue.onMounted(() => {
            fetchList();
        });

        return {
            list,
            pagination,
            loading,
            filters,
            hasFilters,
            selectedRows,
            hasSelection,
            handleSearch,
            clearFilters,
            handlePageChange,
            handleSelectionChange,
            deleteItem,
            batchDelete
        };
    }
});
```

## API 응답 처리 패턴

> ⚠️ 이 프로젝트의 BE API 응답은 `{result_code, result_message, data}` 형식입니다.
> `success` 필드는 **사용하지 않습니다**. `result_code`로만 성공/에러를 판단합니다.

### 표준 응답 구조

```json
{
  "result_code": "I0001",
  "result_message": "정상적으로 처리되었습니다.",
  "data": { ... }
}
```

### 응답 처리 유틸 (useApi에 포함)

```javascript
// composables/useApi.js
export const useApi = () => {
    const loading = Vue.ref(false);

    /**
     * API 요청 실행
     * @param {string} method HTTP 메서드
     * @param {string} url API 경로
     * @param {object} data 요청 데이터
     * @returns {Promise} 응답 데이터 (data 필드)
     */
    const request = async (method, url, data = null) => {
        loading.value = true;
        try {
            const config = { method, url };
            if (method === 'get') {
                config.params = data;
            } else {
                config.data = data;
            }
            const res = await axios(config);
            const body = res.data;

            // result_code 기반 성공/에러 판단 (success 필드 미사용)
            if (body.result_code && body.result_code.startsWith('E')) {
                ElMessage.error(body.result_message || '오류가 발생했습니다.');
                throw new Error(body.result_message);
            }

            return body.data || body;
        } catch (error) {
            if (error.response) {
                const status = error.response.status;
                if (status === 401) {
                    // JWT 만료 → 로그인 페이지
                    ElMessage.error('인증이 만료되었습니다. 다시 로그인하세요.');
                    window.location.hash = '#/login';
                } else if (status === 403) {
                    ElMessage.error('접근 권한이 없습니다.');
                } else {
                    ElMessage.error(error.response.data?.result_message || '서버 오류');
                }
            }
            throw error;
        } finally {
            loading.value = false;
        }
    };

    return { request, loading };
};
```

### result_code 체계

| 코드 패턴 | 의미 | FE 처리 |
|-----------|------|---------|
| `I0001` ~ `I9999` | 정보/성공 | `ElMessage.success(result_message)` |
| `E1001` ~ `E8999` | 비즈니스 에러 | `ElMessage.error(result_message)` |
| `E9999` | 시스템 에러 | `ElMessage.error('시스템 오류')` |

### Mock ↔ 실제 API 전환

```javascript
// Mock 모드 (BE 개발 전)
const { list, fetchList } = useCrud('/api/v1/users.json');

// 실제 API 모드 (BE 개발 후)
const { list, fetchList } = useCrud('/api/user');
// ⚠️ useCrud 내부에서 apiPath가 .json으로 끝나면 Mock, 아니면 실제 API
```

## 사용 가이드

1. **useCrud**: 데이터 CRUD 작업
   - fetchList: 목록 조회
   - fetchById: 상세 조회
   - create: 생성
   - update: 수정
   - deleteItem: 삭제
   - batchDelete: 일괄 삭제

2. **useSearch**: 검색/필터링
   - filters: 현재 필터 상태
   - hasFilters: 필터 적용 여부
   - clearFilters: 필터 초기화
   - updateFilter: 필터 업데이트

3. **useTable**: 테이블 상태
   - selectedRows: 선택된 행
   - selectedIds: 선택된 ID
   - hasSelection: 선택 여부
   - handleSelectionChange: 선택 변경
   - handleSort: 정렬

## 체크리스트

- [ ] useCrud 구현 (fetchList, fetchById, create, update, deleteItem, batchDelete)
- [ ] useSearch 구현 (filters, clearFilters, updateFilter)
- [ ] useTable 구현 (selectedRows, handleSelectionChange, handleSort)
- [ ] Composable 파일 위치: `composables/` 디렉토리
- [ ] API 경로 매개변수 지정
- [ ] 페이징 처리
- [ ] 에러 처리
- [ ] 성공 메시지
- [ ] 테스트 케이스 작성
