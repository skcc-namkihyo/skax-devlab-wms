---
description: "List 및 Edit 전체 페이지 패턴 | Complete List and Edit page templates"
---

# fe-page-crud

## 개요

완전한 List 페이지와 Edit(생성/수정) 페이지 템플릿을 제공합니다. 검색, 페이징, 테이블, 생성/수정 폼을 포함합니다.

**사용 시점**: 새로운 CRUD 페이지가 필요할 때

## 템플릿 / 패턴

### List 페이지

```javascript
// views/user/pages/List.js
const { defineComponent, onMounted } = Vue;
const { useRouter } = VueRouter;  // CDN 전역 변수 사용 (import 금지)
import { useCrud } from '../../../composables/useCrud.js';
import { useSearch } from '../../../composables/useSearch.js';
import { useTable } from '../../../composables/useTable.js';

export default defineComponent({
    name: 'UserList',
    template: `
        <div>
            <!-- 페이지 헤더 -->
            <page-header title="사용자 관리" :breadcrumbs="['관리', '사용자 관리']"></page-header>

            <!-- 검색 폼 -->
            <div class="search-form mb-5 p-5 bg-light">
                <el-form :model="filters" inline>
                    <el-form-item label="이름">
                        <el-input v-model="filters.userName" placeholder="검색..."></el-input>
                    </el-form-item>
                    <el-form-item label="상태">
                        <el-select v-model="filters.isActive" placeholder="선택" clearable>
                            <el-option label="활성" :value="true"></el-option>
                            <el-option label="비활성" :value="false"></el-option>
                        </el-select>
                    </el-form-item>
                    <el-button type="primary" @click="handleSearch">검색</el-button>
                    <el-button @click="clearFilters">초기화</el-button>
                </el-form>
            </div>

            <!-- 액션 바 -->
            <div class="action-bar mb-5 flex justify-between">
                <div>
                    <el-button type="primary" @click="handleCreate">+ 생성</el-button>
                    <el-button type="danger" :disabled="!hasSelection" @click="handleBatchDelete">
                        삭제 ({{ selectionCount }})
                    </el-button>
                </div>
            </div>

            <!-- 테이블 -->
            <el-table
                :data="list"
                stripe
                border
                v-loading="loading"
                @selection-change="handleSelectionChange"
            >
                <el-table-column type="selection" width="50"></el-table-column>
                <el-table-column prop="userId" label="ID" width="100"></el-table-column>
                <el-table-column prop="userName" label="이름" min-width="150"></el-table-column>
                <el-table-column prop="userEmail" label="이메일" min-width="200"></el-table-column>
                <el-table-column label="상태" width="100">
                    <template #default="{ row }">
                        <el-tag :type="row.isActive ? 'success' : 'danger'">
                            {{ row.isActive ? '활성' : '비활성' }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column label="작업" width="150" fixed="right">
                    <template #default="{ row }">
                        <el-button type="primary" size="small" @click="handleEdit(row)">수정</el-button>
                        <el-button type="danger" size="small" @click="handleDelete(row)">삭제</el-button>
                    </template>
                </el-table-column>
            </el-table>

            <!-- 페이징 -->
            <el-pagination
                v-model:current-page="pagination.page"
                :page-size="pagination.limit"
                :total="total"
                @current-change="handlePageChange"
                class="mt-5"
            ></el-pagination>
        </div>
    `,
    setup() {
        const router = useRouter();
        const { list, total, pagination, loading, fetchList, deleteItem, batchDelete } = useCrud('/user');
        const { filters, clearFilters } = useSearch({ userName: '', isActive: null });
        const { selectedRows, hasSelection, selectionCount, handleSelectionChange } = useTable(list.value);

        /**
         * 검색
         */
        const handleSearch = async () => {
            pagination.page = 1;
            await fetchList(filters);
        };

        /**
         * 페이지 변경
         */
        const handlePageChange = async () => {
            await fetchList(filters);
        };

        /**
         * 생성 페이지로 이동
         */
        const handleCreate = () => {
            router.push('/user/edit');
        };

        /**
         * 수정 페이지로 이동
         */
        const handleEdit = (row) => {
            router.push(`/user/edit/${row.userId}`);
        };

        /**
         * 단일 삭제
         */
        const handleDelete = (row) => {
            ElMessageBox.confirm(`${row.userName}을(를) 삭제하시겠습니까?`, '삭제 확인')
                .then(() => deleteItem(row.userId))
                .catch(() => {});
        };

        /**
         * 일괄 삭제
         */
        const handleBatchDelete = () => {
            const selectedIds = selectedRows.value.map(row => row.userId);
            ElMessageBox.confirm(`선택된 ${selectedIds.length}개 항목을 삭제하시겠습니까?`, '삭제 확인')
                .then(() => batchDelete(selectedIds))
                .catch(() => {});
        };

        /**
         * 초기 로드
         */
        onMounted(() => {
            fetchList();
        });

        return {
            list,
            total,
            pagination,
            loading,
            filters,
            selectedRows,
            hasSelection,
            selectionCount,
            handleSearch,
            handlePageChange,
            clearFilters,
            handleSelectionChange,
            handleCreate,
            handleEdit,
            handleDelete,
            handleBatchDelete
        };
    }
});
```

### Edit 페이지 (생성/수정 통합)

```javascript
// views/user/pages/Edit.js
const { defineComponent, ref, onMounted, computed } = Vue;
const { useRoute, useRouter } = VueRouter;  // CDN 전역 변수 사용 (import 금지)
import { useCrud } from '../../../composables/useCrud.js';

export default defineComponent({
    name: 'UserEdit',
    template: `
        <div>
            <!-- 페이지 헤더 -->
            <page-header
                :title="isEdit ? '사용자 수정' : '사용자 생성'"
                :breadcrumbs="breadcrumbs"
            ></page-header>

            <!-- 폼 -->
            <el-form
                ref="formRef"
                :model="form"
                :rules="formRules"
                label-width="120px"
                class="form-container"
            >
                <el-form-item label="이름" prop="userName">
                    <el-input v-model="form.userName" placeholder="사용자 이름"></el-input>
                </el-form-item>

                <el-form-item label="이메일" prop="userEmail">
                    <el-input
                        v-model="form.userEmail"
                        type="email"
                        placeholder="이메일"
                        :disabled="isEdit"
                    ></el-input>
                </el-form-item>

                <el-form-item label="비밀번호" prop="password" v-if="!isEdit">
                    <el-input
                        v-model="form.password"
                        type="password"
                        placeholder="비밀번호"
                    ></el-input>
                </el-form-item>

                <el-form-item label="활성상태">
                    <el-switch v-model="form.isActive"></el-switch>
                </el-form-item>

                <el-form-item>
                    <el-button
                        type="primary"
                        @click="handleSubmit"
                        :loading="loading"
                    >{{ isEdit ? '수정' : '생성' }}</el-button>
                    <el-button @click="goBack">취소</el-button>
                </el-form-item>
            </el-form>
        </div>
    `,
    setup() {
        const route = useRoute();
        const router = useRouter();
        const { currentItem, loading, fetchById, create, update } = useCrud('/user');
        const isEdit = ref(false);

        const form = Vue.reactive({
            userName: '',
            userEmail: '',
            password: '',
            isActive: true
        });

        const formRules = {
            userName: [
                { required: true, message: '이름은 필수입니다.' }
            ],
            userEmail: [
                { required: true, message: '이메일은 필수입니다.' },
                { type: 'email', message: '유효한 이메일을 입력하세요.' }
            ],
            password: [
                {
                    required: true,
                    message: '비밀번호는 필수입니다.',
                    trigger: 'blur',
                    condition: !isEdit.value
                },
                {
                    min: 8,
                    message: '비밀번호는 8자 이상이어야 합니다.',
                    trigger: 'blur',
                    condition: !isEdit.value
                }
            ]
        };

        const breadcrumbs = computed(() => {
            return ['관리', '사용자 관리', isEdit.value ? '수정' : '생성'];
        });

        /**
         * 폼 제출
         */
        const handleSubmit = async () => {
            try {
                if (isEdit.value) {
                    await update(route.params.id, form);
                } else {
                    await create(form);
                }
                router.back();
            } catch (error) {
                // 에러는 useCrud에서 처리
            }
        };

        /**
         * 돌아가기
         */
        const goBack = () => {
            router.back();
        };

        /**
         * 데이터 로드
         */
        onMounted(async () => {
            if (route.params.id) {
                isEdit.value = true;
                const user = await fetchById(route.params.id);
                form.userName = user.userName;
                form.userEmail = user.userEmail;
                form.isActive = user.isActive;
                // 수정 시 비밀번호는 로드하지 않음
            }
        });

        return {
            form,
            formRules,
            isEdit,
            breadcrumbs,
            loading,
            handleSubmit,
            goBack
        };
    }
});
```

## 핵심 기능

### List 페이지

1. **검색/필터링**: 다양한 조건으로 검색
2. **페이징**: LIMIT/OFFSET 기반 페이징
3. **테이블**: 데이터 표시, 정렬, 선택
4. **액션**: 생성, 수정, 삭제, 일괄 삭제
5. **로딩**: 데이터 로드 중 표시

### Edit 페이지

1. **생성/수정 통합**: 단일 페이지에서 처리
2. **폼 검증**: Element Plus 폼 검증
3. **필드 제어**: 수정 시 이메일 비활성화
4. **에러 처리**: 자동 에러 메시지
5. **네비게이션**: 저장/취소 처리

## 사용 가이드

1. **List 페이지 생성**: `views/{module}/pages/List.js`
2. **Create 페이지 생성**: `views/{module}/pages/Create.js`
3. **Edit 페이지 생성**: `views/{module}/pages/Edit.js`
4. **라우트 등록**: `router.js`에 경로 추가 (중앙 관리)
5. **메뉴 등록**: `sidebar.js`에 메뉴 항목 추가
6. **API 경로**: `/[domain]/list`, `/[domain]`, `/[domain]/{id}`
7. **Composables 사용**: useCrud, useSearch, useTable (로컬 import 허용)

## 체크리스트

- [ ] List 페이지 생성
- [ ] Edit 페이지 생성
- [ ] 라우트 등록
- [ ] API 경로 확인
- [ ] 검색/필터링 기능
- [ ] 페이징 기능
- [ ] 테이블 선택 기능
- [ ] 생성/수정/삭제 기능
- [ ] 폼 검증
- [ ] 에러 처리
- [ ] 메시지 표시
- [ ] 스타일 적용
