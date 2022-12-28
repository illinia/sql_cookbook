### 3.1.3 데이터 세팅하기
```shell
docker cp /Users/taemin/mysql_study/sql_tunning ecbf59cb2aa4:/tmp
docker exec -it mysql-container bash
```
```bash
cd tmp/sql_tunning/SQLtune-main/
mysql -u root -p < data_setting.sql

mysql -u root -p
```
```sql
use tuning;
select count(1) from 사원;
```

### 3.2.2 기본 실행 계획 항목 분석

* id
  * 실행 순서 표시 숫자. sql 문이 수행되는 차례, 조인시 같은 id
* select_type
  * SIMPLE
    * union 이나 내부 쿼리가 없는 select 문 이라는 걸 의미
  * PRIMARY
    * 서브쿼리가 포함시 첫 번째 select 문에 해당하는 구문에 표시
    * 서브쿼리를 감싸는 외부 쿼리, union 포함된 첫번째 select 키워드가 작성된 구문
    * union all 구문으로 통합된 sql 문에서 처음 select 구문이 작성된 쿼리가 먼저 접근한다는 의미
  * SUBQUERY
    * 독립적으로 수행되는 서브쿼리. 옵티마이저가 서브쿼리임을 인지하고 있다.
    * select 절의 스칼라 서브쿼리, where 중첩 서브쿼리일 경우
  * DERIVED
    * from 절에 작성된 서브쿼리, 별도 임시 테이블인 인라인 뷰
  * UNION
    * union, union all 구문으로 합쳐진 select 문에서 첫번째 select 제외한 이후의 select 구문에 해당
  * UNION RESULT
    * union all 이 아닌 union 구문으로 select 절을 결합했을 때 출력
    * union 은 출력 결과에 중복이 없는 유일한 속성, 각 select 절에서 데이터 가져와 정렬, 중복체크
    * 별도의 메모리, 디스크에 임시 테이블 만들어 중복 제거하겠다는 의미
  * DEPENDENT SUBQUERY
    * union, union all 서브쿼리가 메인 테이블 영향 받는 경우
    * union 으로 연결된 단위 쿼리들 중 처음으로 작성한 단위 쿼리에 해당하는 경우
    * 첫 번째 단위 쿼리가 독립적으로 수행하지 못하고 메인 테이블로부터 값을 공급받는 구조, 성능상 불리
  * UNCACHEABLE SUBQUERY
    * 메모리에 상주하여 재활용되어야 할 서브쿼리가 재사용되지 못할 때 출력
    * 서브쿼리 안에 사용자 정의 함수, 변수가 포함되거나 rand(), uuid() 등을 사용하여 매번 조회시마다 결과가 달라지는 경우
  * MATERIALIZED
    * in 절 구문에 연결된 서브쿼리가 임시 테이블을 생성한 뒤, 조인이나 가공작업을 수행할 때 출력되는 유형
* table
  * 테이블 명 표시
* partitions
* type
  * system
    * 테이블에 데이터가 없거나 하나인 경우
  * const
    * 조회되는 데이터가 1건, 고유 인덱스, 기본 키 사용
  * eq_ref
    * 조인이 수행될 때 드리븐 테이블 데이터에 접근하며 고유 인덱스, 기본 키로 1건의 데이터를 조회하는 방식
    * 드라이빙 테이블과 조인 키가 드리븐 테이블에 유일, 조인 수행시 가장 유리
  * ref
    * eq_ref 유사한 방식, 드리븐 테이블의 데이터 접근 범위가 2개 이상일 경우
  * ref_or_null
    * ref 유사 is null 구문에 인덱스를 활용
    * null 데이터 양이 적다면 ref_of_null 방식 활용시 효율적
    * 검색할 null 데이터 양이 많다면 튜닝의 대상
  * range
    * 테이블 내 연속 데이터 범위 조회 =, <>, >, >=, <, <=, is null, <=>, between, in 범위 스캔
  * fulltext
    * 텍스트 검색을 빠르게 하기 위해 전문 인덱스 사용
  * index_merge
    * 결합된 인덱스, 두 개 이상의 인덱스가 병합되어 동시에 적용, 전문 인덱스는 제외
  * index
    * 인덱스 풀 스캔. 물리적 인덱스 블록
  * all
    * 테이블 풀 스캔, 활용할 수 있는 인덱스가 없거나 비효율적이라고 옵티마이저가 판단하면 선택
    * 전체 테이블 10 ~ 20 퍼 이상 데이터를 조회할때는 인덱스보다 유리할 수 있다.
* possible_keys
  * 옵티마이저가 최적화하고자 사용할 수 있는 인덱스 목록 출력
* key
  * 옵티마이저가 최적화시 사용한 기본 키 혹 인덱스 명
  * 어느 인덱스로 검색했는지 확인할 수 있으므로 튜닝의 대상이 된다.
* key_len
  * 사용한 인덱스 바이트 수
  * utf-8 기준 int 데이터 유형은 단위당 4바이트, varchar 데이터 유형은 3바이트
* ref
  * 테이블 조인시 어떤 조건으로 엑세스되었는지 정보
* rows
  * 접근하는 데이터의 모든 행 예측 항목
* filtered
  * db 엔진으로 가져온 데이터 대상 필터 조건에 따라 어느 정도 비율로 제거했는지 의미하는 항목
* extra
  * 어떻게 수행할 것이지 보여주는 항목
  * Distinct
    * 중복이 제거되어 유일한 값을 찾을 때 출력되는 정보. distinct, union 이 포함될때
  * Using where
    * where 절의 필터 조건을 사용해 mysql 엔진으로 가져온 데이터를 추출할 것이라는 의미
  * Using temporary
    * 중간 결과 저장하고자 임시 테이블 생성
    * 메모리에 생성하거나 디스크에 생성하면 성능 저하될 수 있다
  * Using index
    * 인덱스만 읽어서 요청사항 처리 가능한 경우. 커버링 인덱스, 효율적
  * Using filesort
    * 정렬 필요 데이터를 메모리에 올려 정렬 작업 수행
  * Using join buffer
    * 조인 수행 위해 중간 데이터 결과 저장하는 조인 버퍼 사용
  * Using union/ Using intersect/ Using sort_union
    * 인덱스가 병합되어 실행될때 어떻게 병합했는지 정보 출력
    * Using union 은 인덱스들을 합집합처럼 모두 결합, sql 문이 or 구문으로 작성된 경우
    * Using intersect 는 인덱스들을 교집합처럼 추출, and 구문
    * Using sort_union where 절의 or 구문이 동등조건이 아닐때
  * Using index condition
    * 필터 조건을 스토리지 엔진으로 전달하여 필터링 작업에 대한 mysql 엔진의 부하를 줄이는 방식
    * 스토리지 엔진 결과를 mysql 엔진으로 전송하는 데이터양을 줄여 성능 효율 높이는 방법
  * Using index condition(BKA)
    * 데이터 검색 위해 배치 키 액세스 사용하는 방식
  * Using index for group-by
    * group by, distinct 포함될때는 인덱스로 정렬 작업 수행
  * Not exists
    * 하나의 일치 행을 찾으면 추가로 행을 더 검색하지 않아도 될 때 출력

### 3.2.4 확장된 실행 계획 수행

* explain format = traditional
* explain format = tree(안됨)
* explain format = json
* explain analyze

## 3.3 프로파일링

### 3.3.2 프로파일링 결과 해석하기

* starting: SQL 문 시작
* checking permissions: 필요 권한 확인
* Opening tables: 테이블을 열기
* After opening tables: 테이블을 연 이후
* System lock: 시스템 잠금
* Table lock: 테이블 잠금
* init: 초기화
* optimizing: 최적화
* statistics: 통계
* preparing: 준비
* executing: 실행
* Sending data: 데이터 보내기
* end: 끝
* query end: 질의 끝
* closing tables: 테이블 닫기
* Unlocking tables: 잠금 해제 테이블
* freeing items: 항목 해방
* updating status: 상태 업데이트
* cleaning up: 청소