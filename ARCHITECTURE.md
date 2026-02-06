# SSOT Architecture Contract

STAGE 1 — Truth fixation — ✅  
STAGE 2 — State — ✅  
STAGE 3 — Audit — ✅  
STAGE 4 — Snapshot — ✅  
STAGE 5 — Startup gate — ✅  
STAGE 6 — Report (Single View of Truth) — ✅  

---

## WAL — CONTRACT FIXATION

### Scope
WAL (Write-Ahead Log) является частью данных Postgres и существует
исключительно внутри `PGDATA`, размещённого на PVC,
перечисленных в `/opt/ssot/state/active_pvc.list`.

WAL не существует вне PVC и не рассматривается как host-level артефакт.

---

### Audit Status
WAL включён в SSOT **как задекларированный компонент**, но:

- размер WAL НЕ аудируется
- скорость роста WAL НЕ аудируется
- политика retention WAL НЕ enforced
- WAL-алерты НЕ являются частью SSOT

Это состояние **осознанное и зафиксированное**.

---

### Boundaries
SSOT гарантирует:
- локальность WAL (внутри PVC)
- связь WAL с жизненным циклом Postgres Pod

SSOT НЕ гарантирует:
- лимиты размера WAL
- настройку retention WAL
- защиту диска от роста WAL

---

### Responsibility Split
- Зона ответственности SSOT заканчивается на факте существования и локальности WAL
- Управление WAL (лимиты, алерты, очистка) относится к OPS-слою

---

### Architectural Risk
Неконтролируемый рост WAL может привести к исчерпанию PVC
и недоступности Postgres.

Риск:
- известен
- принят
- зафиксирован как архитектурный долг

---

### Stage Mapping
Решение относится к:
- STAGE 3 — AUDIT
- Section 3.3 — WAL

STAGE 3.3 считается **COMPLETE**.

STAGE 3.4 — Orphan PVC / local-path — ✅  
(local-path восстановлен, kubelet перезапущен)

OPS NOTE:  
WAL ограничен на уровне Postgres (`max_wal_size`, `min_wal_size`)
и мониторится внешним read-only OPS-скриптом.
Это **НЕ влияет** на полноту STAGE 3.3.

---

## OPS OBSERVABILITY (OUT OF SSOT)

### WAL — Operational Monitoring

WAL мониторится **вне SSOT**.

OPS-слой:
- не мутирует Postgres
- не пишет в SSOT
- не влияет на стадии SSOT
- работает в read-only режиме

---

### Реализованные меры

- лимиты WAL на уровне Postgres
- наблюдение PVC / диска на host-level
- информационные алерты без enforcement

---

### Architectural Statement

SSOT остаётся **единственным источником архитектурной истины**.  
OPS-наблюдаемость дополняет, но не расширяет SSOT.

---

## STAGE 7 — Snapshot fixation — ✅

### Цель
Зафиксировать факт существования snapshot SSOT PVC
как архитектурного артефакта,
**без придания ему свойств бэкапа или восстановления**.

---

### Определение
Snapshot:
- фиксирует состояние PVC
- отражает storage-факт
- не является бэкапом
- не используется для восстановления

---

### Статус
STAGE 7 считается **COMPLETE**.

---

## STAGE 8 — Backup / Restore drills — IMPLEMENTED

### Реализовано

- Logical backup Postgres (`pg_dump`) — ✅
- Запуск из OPS-контекста (`kubectl exec`) — ✅
- Хранилище бэкапов: `/opt/ssot-backup` (НЕ SSOT PVC) — ✅
- Предпроверка свободного места — ✅
- Retention policy (cron) — ✅
- Restore-drill выполнен в изолированном Pod — ✅

SSOT PVC **НЕ использовался** при restore.

---

### Границы ответственности

SSOT:
- гарантирует локальность и runtime-целостность данных

SSOT НЕ гарантирует:
- Disaster Recovery
- PITR

OPS отвечает за:
- бэкапы
- хранение
- restore
- restore-drill

---

### Статус
STAGE 8 — **IMPLEMENTED**.  
Восстановимость возможна, но требует OPS-действия.

---

## STAGE 9 — Replication / HA — DESIGN (FROZEN)

Репликация и HA **осознанно не реализованы**.

Обоснование:
- SSOT = единственный источник истины
- реплики вводят неопределённость
- автоматический failover создаёт риск split-brain

STAGE 9 остаётся **DESIGN и FROZEN**  
до явного пересмотра архитектурных принципов.

---

## STAGE 10 — Observability (Grafana / Prometheus) — IMPLEMENTED

### Назначение
Observability используется **исключительно для фиксации runtime-фактов**
и не влияет на SSOT.

---

### Реализованные компоненты

- Prometheus (read-only metrics)
- kube-state-metrics (state visibility)
- Grafana (UI слой без persistence)

---

### Наблюдаемые сигналы

- доступность Postgres
- состояние Pods / Nodes
- заполнение PVC / диска
- факт выполнения backup / restore-drill
- SSOT-события через ConfigMap-маркеры

---

### Границы

Observability:
- не мутирует систему
- не инициирует действия
- не является источником истины

---

### Архитектурное заявление

Grafana повышает **видимость**,  
но не расширяет и не ослабляет SSOT.

---

### Статус
STAGE 10 считается **IMPLEMENTED**.

---

# ARCHITECTURE STATE

Документ:
- логически непротиворечив
- завершён
- пригоден для freeze
- является архитектурным контрактом














<!-- OLD -->
STAGE 1 — Truth fixation — ✅
STAGE 2 — State — ✅
STAGE 3 — Audit — ✅
STAGE 4 — Snapshot — ✅
STAGE 5 — Startup gate — ✅
STAGE 6 — Report (Single View of Truth) — ✅
---

## WAL — CONTRACT FIXATION

### Scope
WAL (Write-Ahead Log) is part of Postgres data and exists only inside PGDATA,
which is stored exclusively on PVC listed in `/opt/ssot/state/active_pvc.list`.

WAL does not exist outside PVC and is not considered a host-level artifact.

---

### Audit Status
WAL is included in SSOT **as a declared component**, but:

- WAL size is NOT audited
- WAL growth rate is NOT audited
- WAL retention policy is NOT enforced
- WAL-related alerts are NOT part of SSOT

This state is intentional and explicit.

---

### Boundaries
SSOT guarantees:
- WAL locality (inside PVC)
- WAL coupling to Postgres Pod lifecycle

SSOT does NOT guarantee:
- WAL size limits
- WAL retention tuning
- Disk space protection from WAL growth

---

### Responsibility Split
- SSOT responsibility ends at data locality and existence.
- Operational control of WAL (limits, alerts, cleanup) belongs to OPS layer.

---

### Architectural Risk
Unbounded WAL growth may lead to PVC exhaustion and Postgres unavailability.

This risk is:
- Known
- Accepted
- Tracked as architectural debt

---

### Stage Mapping
This decision is part of:
- STAGE 3 — AUDIT
- Section 3.3 — WAL

STAGE 3.3 is considered **COMPLETE** under this definition.

STAGE 3.4 — Orphan PVC / local-path — ✅ (local-path restored, kubelet restarted)
OPS NOTE:
WAL is limited at Postgres level (max_wal_size/min_wal_size) and monitored via external read-only PVC alert script.
This control exists OUTSIDE SSOT and does NOT affect STAGE 3.3 completeness.
---

## OPS OBSERVABILITY (OUT OF SSOT)

### WAL — Operational Monitoring

WAL (Write-Ahead Log) is operationally monitored **outside of SSOT**.

This monitoring layer:
- does NOT mutate Postgres
- does NOT write into SSOT state
- does NOT affect SSOT stages
- operates in read-only mode

---

### Implemented Controls

The following controls are implemented and verified:

- WAL size is **limited at Postgres level**
  - `max_wal_size`
  - `min_wal_size`

- WAL / PVC usage is **observed at host level**
  - via periodic OPS script
  - without container or database mutation

- Alerting is **informational**
  - signals risk
  - does not enforce actions

---

### Scheduling

OPS WAL/PVC monitoring is executed periodically via cron.

This scheduling:
- ensures early detection of disk pressure
- does not participate in SSOT logic
- does not change audit semantics

---

### Architectural Statement

SSOT remains the **Single Source of Truth**.

OPS monitoring:
- complements SSOT
- does not extend SSOT responsibilities
- does not redefine audit guarantees

This separation is intentional.

---

### Status

- STAGE 3.3 — WAL: ✅ COMPLETE
- STAGE 3.4 — Orphan PVC / local-path: ✅ COMPLETE
- Architecture state: **CONSISTENT AND PROVABLE**
## STAGE 7 — Snapshot fixation — ✅

### Цель
Зафиксировать факт существования snapshot SSOT PVC
как архитектурного артефакта,
**без придания ему свойств бэкапа или механизма восстановления**.

---

### Определение
Snapshot в рамках SSOT:
- является **слепком состояния PVC**
- фиксирует **storage-факт**
- отражает состояние данных **на момент времени**
- НЕ является копией данных
- НЕ является механизмом восстановления

---

### Текущее состояние
- Snapshot SSOT PVC: ✅ СУЩЕСТВУЕТ
- Привязка к конкретному PVC: ✅ ДА
- Архитектурная фиксация: ✅ ДА
- Использование в runtime: ❌ НЕТ
- Использование для восстановления: ❌ НЕТ

---

### Границы snapshot

Snapshot МОЖЕТ:
- зафиксировать состояние данных на момент времени
- использоваться как reference / forensic-артефакт
- подтверждать факт существования данных

Snapshot НЕ МОЖЕТ:
- гарантировать восстановимость
- заменять backup
- обеспечивать PITR
- использоваться для Disaster Recovery

---

### Взаимосвязь со STAGE 8
Snapshot:
- НЕ закрывает требования STAGE 8
- НЕ является частью backup-стратегии
- НЕ снижает риск потери данных

STAGE 8 начинается **после осознанного признания ограничений snapshot**.

---

### Архитектурное заявление
Snapshot существует.
Его ограничения известны.
Иллюзий восстановления нет.

---

### Статус
STAGE 7 считается **COMPLETE**.
Функциональность намеренно ограничена.

## STAGE 8 — Backup / Restore drills — DESIGN

### Цель
Спроектировать резервное копирование и восстановление Postgres,
размещённого на SSOT PVC, без изменения текущей SSOT-архитектуры.

---

### Базовые определения
- WAL **НЕ является бэкапом**
- WAL **НЕ обеспечивает восстановление без base backup**
- SSOT snapshot — это **слепок состояния архитектуры**, а не копия данных
- Наличие WAL **НЕ эквивалентно** возможности восстановления

---

### Текущее состояние
- Логический бэкап (pg_dump): ❌ НЕ РЕАЛИЗОВАН
- Физический base backup (pg_basebackup): ❌ НЕ РЕАЛИЗОВАН
- Хранилище бэкапов: ❌ НЕ ОПРЕДЕЛЕНО
- Процедура восстановления: ❌ НЕ ОПИСАНА
- Restore-drill (проверка восстановления): ❌ НЕ ПРОВОДИЛАСЬ

---

### Типы бэкапов (DESIGN)

#### 1. Logical backup
- Инструмент: `pg_dump`
- Назначение:
  - защита от логических ошибок
  - восстановление отдельных объектов
- Ограничения:
  - медленный
  - не подходит для больших объёмов данных
  - не обеспечивает PITR

#### 2. Physical base backup
- Инструмент: `pg_basebackup`
- Назначение:
  - полное восстановление кластера
- Требования:
  - совместимость версии Postgres
  - согласованность с WAL
  - контроль дискового пространства

---

### Хранилище бэкапов (DESIGN)

Бэкапы **НЕ хранятся на SSOT PVC**.

Допустимые варианты (выбор на этапе IMPLEMENTATION):
- Отдельный диск на хосте
- Отдельный PVC (non-SSOT)
- Внешнее хранилище (S3 / NFS / Object Storage)

Обязательные требования:
- Физическое и логическое разделение с SSOT PVC
- Доступность из OPS-контекста
- Возможность мониторинга свободного места

---

### Предпроверки перед бэкапом (MANDATORY)
Перед запуском любого бэкапа обязаны выполняться проверки:
- доступности хранилища бэкапов
- свободного дискового пространства
- минимального порога свободного места (X% или X GiB)

При невыполнении условий:
- бэкап **НЕ запускается**
- фиксируется отказ запуска

---

### Restore-drill (DESIGN)
Процедура восстановления обязана включать:
- разворот бэкапа в изолированное окружение
- инициализацию Postgres
- проверку доступности базы данных

Restore-drill:
- НЕ выполняется автоматически
- НЕ влияет на production
- проводится вручную или по регламенту OPS

---

### Границы ответственности

#### SSOT гарантирует:
- локальность данных (PVC)
- целостность данных в runtime
- наличие WAL как части Postgres

#### SSOT НЕ гарантирует:
- восстановимость данных
- наличие бэкапов
- Disaster Recovery
- Point-in-Time Recovery (PITR)

#### OPS отвечает за:
- создание бэкапов
- хранение бэкапов
- мониторинг места под бэкапы
- восстановление данных
- проведение restore-drill

---

### Риски
- Потеря SSOT PVC без бэкапа приводит к **безвозвратной потере данных**
- Отсутствие restore-drill создаёт ложное чувство защищённости

Риски:
- Осознаны
- Приняты
- Явно задокументированы

---

### Критерии перехода в IMPLEMENTED
STAGE 8 может быть переведён в IMPLEMENTED, если:
- реализован минимум один реальный бэкап
- определено место хранения
- описана процедура восстановления
- выполнен хотя бы один restore-drill

---

### Статус
STAGE 8 находится в состоянии **DESIGN**.
Реализация и восстановление не выполнялись.
## STAGE 9 — Replication / HA — DESIGN

### Цель
Спроектировать репликацию и отказоустойчивость Postgres,
размещённого на SSOT PVC, **без нарушения принципа Single Source of Truth (SSOT)**.

---

### Базовые определения
- Репликация **НЕ является бэкапом**
- HA **НЕ гарантирует сохранность данных**
- SSOT = **единственная точка истины**
- Любая реплика = **вторичная копия**, не источник истины

---

### Текущее состояние
- Репликация Postgres: ❌ НЕ РЕАЛИЗОВАНА
- Standby / replica pod: ❌ ОТСУТСТВУЕТ
- Failover-механизм: ❌ НЕ ОПИСАН
- Автоматическое переключение: ❌ ОТСУТСТВУЕТ
- Документированная стратегия HA: ❌ НЕТ

---

### Модели репликации (DESIGN)

#### 1. Physical Streaming Replication
- Механизм: Postgres streaming replication
- Тип:
  - synchronous — НЕ ВЫБРАН
  - asynchronous — НЕ ВЫБРАН
- Особенности:
  - реплика требует base backup
  - реплика зависит от WAL
- Ограничения:
  - потеря primary возможна с потерей последних транзакций
  - реплика **НЕ SSOT**

#### 2. Logical Replication
- Использование publication / subscription
- Назначение:
  - выборочная репликация
  - интеграции
- Ограничения:
  - не HA
  - не обеспечивает полный failover

---

### Размещение реплик (DESIGN)

Реплики **НЕ используют SSOT PVC**.

Допустимые варианты:
- отдельный PVC (non-SSOT)
- отдельный node
- отдельный кластер

Требования:
- физическое и логическое разделение с SSOT
- невозможность автоматического promote до primary

---

### Failover (DESIGN)

Failover:
- НЕ автоматический
- НЕ скрытый
- НЕ прозрачный

Допустимые варианты:
- ручной promote
- регламентированный OPS-процесс
- обязательная фиксация утраты SSOT-непрерывности

Автоматический failover:
- ❌ ЗАПРЕЩЁН на этапе DESIGN

---

### Split-brain
Риск split-brain:
- признан
- не закрыт автоматически
- предотвращается процессом, а не автоматикой

Любой promote:
- требует явного решения OPS
- фиксируется как архитектурное событие

---

### Границы ответственности

#### SSOT гарантирует:
- одну точку записи
- одну точку истины
- целостность primary данных

#### SSOT НЕ гарантирует:
- отказоустойчивость
- доступность при падении primary
- автоматическое восстановление

#### OPS отвечает за:
- сопровождение реплик
- процедуры promote / demote
- управление failover
- принятие риска потери данных

---

### Риски
- Потеря primary приводит к остановке сервиса
- Promote реплики нарушает SSOT-непрерывность
- Автоматический HA создаёт риск скрытого split-brain

Риски:
- Осознаны
- Приняты
- Явно задокументированы

---

### Критерии перехода в IMPLEMENTED
STAGE 9 может быть переведён в IMPLEMENTED, если:
- выбран тип репликации
- определено размещение реплик
- описана процедура promote
- задокументирован допустимый сценарий потери данных
- явно зафиксирован отказ от автоматического failover

## STAGE 10 — Observability — DESIGN

### Цель
Обеспечить наблюдаемость состояния системы в runtime
без вмешательства в SSOT и без изменения архитектурных гарантий.

Observability предназначена для **фиксации фактов**, а не для управления системой.

---

### Базовые определения
- Observability **НЕ является SSOT**
- Observability **НЕ влияет на архитектурные стадии**
- Observability **НЕ выполняет мутации**
- Observability **НЕ закрывает риски**, а делает их видимыми

---

### Область наблюдения (DESIGN)

Допустимые объекты наблюдения:
- Postgres (доступность, нагрузка, latency)
- WAL (косвенно, через PVC / диск)
- PVC / диск (заполнение, давление)
- Pods / Nodes (состояние, рестарты)
- Backup / OPS-процессы (факт выполнения)

---

### Источники данных
- Метрики (metrics)
- Логи (logs)
- События (events)

Observability может агрегировать данные из:
- Kubernetes
- Postgres
- Host-level источников

---

### Границы ответственности

#### Observability МОЖЕТ:
- читать состояние
- строить графики
- формировать алерты
- сигнализировать о рисках

#### Observability НЕ МОЖЕТ:
- изменять конфигурацию
- запускать восстановление
- влиять на SSOT
- принимать архитектурные решения

---

### Алерты (DESIGN)

Алерты:
- носят информационный характер
- не инициируют автоматические действия
- не считаются частью SSOT

Назначение алертов:
- раннее обнаружение деградации
- сигнализация о приближении рисков

---

### Взаимодействие с SSOT

- Observability **НЕ расширяет SSOT**
- Observability **НЕ участвует в аудитах**
- Observability **НЕ является источником истины**

SSOT остаётся **единственным источником архитектурной истины**.

---

### Риски
- Отсутствие Observability = реакция постфактум
- Ошибочная интерпретация метрик = ложные выводы

Риски:
- Осознаны
- Приняты
- Не автоматизированы

---

### Критерии перехода в IMPLEMENTED
STAGE 10 может быть переведён в IMPLEMENTED, если:
- определён набор наблюдаемых метрик
- выбраны инструменты наблюдения
- задокументированы границы влияния

---

### Статус
STAGE 10 находится в состоянии **DESIGN**.  
Инструменты наблюдения не внедрены.

## STAGE 8 — Backup / Restore drills — IMPLEMENTATION (PARTIAL)

### Реализовано
- Logical backup Postgres через `pg_dump`: ✅
- Запуск из OPS-контекста (kubectl exec): ✅
- Хранилище бэкапов: `/opt/ssot-backup` (вне SSOT PVC): ✅
- Предпроверка свободного места перед бэкапом: ✅
- Бэкап не мутирует SSOT и Postgres runtime: ✅

### Не реализовано
- Restore-процедура: ❌
- Restore-drill: ❌
- Retention policy: ❌
- Автоматическое расписание (cron): ❌

### Архитектурное заявление
STAGE 8 переведён из DESIGN в **PARTIAL IMPLEMENTATION**.  
Восстановимость данных пока **НЕ гарантирована**.

## STAGE 8 — Backup / Restore drills — IMPLEMENTED

### Цель
Реализовать резервное копирование Postgres,
размещённого на SSOT PVC, **без изменения SSOT-архитектуры**
и с явной фиксацией границ ответственности.

---

### Базовые определения
- WAL **НЕ является бэкапом**
- WAL **НЕ обеспечивает восстановление без base backup**
- SSOT snapshot — это **слепок состояния архитектуры**, а не копия данных
- Наличие WAL **НЕ эквивалентно** возможности восстановления

---

### Реализованные механизмы

#### 1. Logical backup (IMPLEMENTED)
- Инструмент: `pg_dump` (внутри Pod)
- Запуск: через `kubectl exec`
- Скрипт: `/opt/ssot-backup/ssot_pg_dump.sh`
- Результат:
  - SQL-дамп базы `trading`
  - Имя файла с timestamp
- Хранилище:
  - `/opt/ssot-backup/dumps`
  - **НЕ SSOT PVC**

---

#### 2. Хранилище бэкапов (IMPLEMENTED)

- Путь: `/opt/ssot-backup`
- Тип: host-level storage
- Разделение с SSOT PVC: ✅ ДА
- Доступ:
  - запись: OPS (root / alex)
  - SSOT: ❌ НЕ ИСПОЛЬЗУЕТ

---

### Предпроверки перед бэкапом (IMPLEMENTED)

Перед выполнением бэкапа:
- проверяется доступность каталога `/opt/ssot-backup`
- проверяется наличие свободного места
- при ошибке:
  - бэкап НЕ запускается
  - ошибка логируется
  - exit с ненулевым кодом

---

### Retention policy (IMPLEMENTED)

- Скрипт: `/opt/ssot-backup/ssot_retention.sh`
- Назначение:
  - удаление устаревших дампов
- Запуск:
  - по cron
- Логирование:
  - `/opt/ssot-backup/backup.log`

---

### Планировщик (IMPLEMENTED)

В `root crontab`:

- Logical backup:

---

### Restore-drill (STATUS)

- Процедура восстановления: ⚠️ ЧАСТИЧНО ОПИСАНА
- Фактический restore-drill: ❌ НЕ ПРОВОДИЛСЯ
- Автоматическое восстановление: ❌ ОТСУТСТВУЕТ

Restore остаётся **осознанным операционным действием OPS**.

---
STAGE 8 — Backup / Restore drills: IMPLEMENTED ✅ (logical backup restored successfully in isolated Postgres Pod via pg_dump restore-drill; SSOT PVC not used; restore reproducibility proven; data completeness not guaranteed by design)


### Границы ответственности

#### SSOT гарантирует:
- локальность данных (PVC)
- целостность данных в runtime
- наличие WAL как части Postgres

#### SSOT НЕ гарантирует:
- восстановимость данных
- Disaster Recovery
- Point-in-Time Recovery (PITR)

#### OPS отвечает за:
- создание бэкапов
- хранение бэкапов
- контроль места
- запуск restore
- проведение restore-drill

---

### Риски
- Потеря SSOT PVC без актуального бэкапа = потеря данных
- Отсутствие регулярного restore-drill

Риски:
- Осознаны
- Приняты
- Явно зафиксированы

---

### Статус
STAGE 8 находится в состоянии **IMPLEMENTED**.

Backup существует.
Retention работает.
Restore возможен, но требует ручного OPS-действия.

STEP 0 — Paths verification: COMPLETED
/opt/ssot-backup exists
/opt/ssot-backup/dumps exists
/opt/ssot/state/active_pvc.list exists

## STAGE 10 — Observability — IMPLEMENTED

### Реализованное состояние

Observability реализована как read-only OPS слой,
не влияющий на SSOT и не изменяющий архитектурные гарантии.

OPS имеет визуальный доступ к:

- состоянию Postgres (availability, restarts)
- использованию PVC / диска
- косвенному росту WAL через filesystem metrics
- факту выполнения backup-процессов
- информационным алертам о рисках

### Архитектурные гарантии

- Observability не мутирует Postgres
- Observability не пишет в SSOT
- Observability не инициирует автоматические действия
- Observability не участвует в restore / failover

### Статус

STAGE 10 считается IMPLEMENTED.

Observability выполняет функцию фиксации фактов.
Принятие решений остаётся за OPS.
## STAGE 9 — Репликация / HA — DESIGN (FROZEN)

Механизмы репликации и высокой доступности (HA) сознательно НЕ реализованы.

Обоснование:
- SSOT определяет единственный авторитетный источник записи
- Любая реплика вводит неопределённость истины
- Автоматический failover создаёт скрытый риск split-brain
- Доступность считается менее приоритетной, чем корректность данных

Это осознанное архитектурное решение.

HA может быть пересмотрена только если:
- частичная потеря данных станет допустимой
- принцип SSOT будет ослаблен
- процедуры failover будут явно переработаны

До этого момента STAGE 9 остаётся в статусе DESIGN и FROZEN.

## STAGE 10 — Observability (Grafana) — IMPLEMENTED

Grafana используется как слой наблюдаемости (Observability),
отделённый от SSOT и не влияющий на архитектурные гарантии.

### Статус
- Grafana: ✅ РАЗВЁРНУТА
- Источник данных: Prometheus
- Влияние на SSOT: ❌ НЕТ
- Мутации системы: ❌ НЕТ

### Назначение
Grafana предназначена исключительно для:
- визуализации метрик
- фиксации runtime-фактов
- раннего обнаружения деградаций

Grafana **не является**:
- источником истины
- механизмом управления
- частью SSOT
- заменой аудита или snapshot

### Наблюдаемые области
- Kubernetes (pods, nodes, restarts)
- PVC / диск (заполнение, давление)
- Postgres (доступность, базовые метрики)
- OPS-процессы (факт выполнения)

### Алерты
- носят информационный характер
- не инициируют автоматические действия
- не считаются архитектурными событиями

### Архитектурное заявление
Grafana повышает видимость состояния системы,
но не расширяет и не ослабляет SSOT.

STAGE 10 считается **IMPLEMENTED**.

## STAGE 10 — Observability (Grafana / Prometheus)

**Статус:** IMPLEMENTED  
**Назначение:** наблюдаемость, контроль backup / restore, без paging и без HA.

### Цели STAGE 10
Grafana используется как единая точка визуального контроля:
- жив ли кластер и его системные компоненты;
- был ли выполнен backup;
- был ли выполнен restore (DRILL);
- всё это — без влияния на production и без сложных операторов.

---

### Компоненты

#### Prometheus
- Развёрнут в namespace `monitoring`.
- Scrape-интервал: 15s.
- Источники метрик:
  - `node-exporter`
  - `kube-state-metrics`
- Используется **только** для чтения метрик и инфо-сигналов.

#### kube-state-metrics
- Развёрнут в `kube-system`.
- Используется как **источник сигналов состояния**, а не для алертов:
  - existence ConfigMap
  - namespace / object visibility
- Ключевая роль — наблюдение за SSOT-событиями.

#### Grafana
- Развёрнута в namespace `monitoring`.
- Доступ через `kubectl port-forward`.
- Datasource: Prometheus (TEST OK).
- Используется **без HA**, **без persistence**, как UI-слой.

---

### Реализованные сигналы (Dashboard)

#### 1. Restore drill (SSOT)
**Источник:** `kube-state-metrics`  
**Механизм:** ConfigMap-маркер

```yaml
kind: ConfigMap
metadata:
  name: ssot-restore-drill
  namespace: trading
## WAL — OPERATIONAL FIXATION (MANDATORY)

### Статус
WAL (Write-Ahead Log) является **обязательным операционным компонентом** Postgres
и рассматривается как **bounded and monitored subsystem**.

Неограниченный рост WAL считается **системной ошибкой**, а не допустимым состоянием.

---

### Обязательные гарантии (REQUIRED)

Для WAL должны выполняться ВСЕ условия:

1. WAL имеет **жёсткие лимиты на уровне Postgres**:
   - `max_wal_size`
   - `min_wal_size`
   - `wal_keep_size` (если нет реплик)

2. Фактический размер WAL **наблюдаем в runtime**:
   - логически (через Postgres)
   - физически (через filesystem / PVC)

3. WAL проверяется **перед выполнением backup**.
   Backup запрещён, если:
   - размер WAL превышает допустимый порог
   - свободное место на PVC ниже безопасного минимума

4. WAL **НЕ очищается автоматически** и **НЕ архивируется**,
   если это не зафиксировано отдельным архитектурным решением.

---

### Границы ответственности

#### SSOT гарантирует:
- размещение WAL внутри PGDATA
- связность WAL с жизненным циклом Postgres Pod

#### SSOT НЕ гарантирует:
- автоматическое управление WAL
- восстановимость через WAL
- PITR
- очистку WAL

#### OPS ОБЯЗАН:
- установить лимиты WAL
- наблюдать рост WAL
- фиксировать WAL-статус
- предотвращать опасные операции (backup / restore) при риске переполнения

---

### WAL Status Model

WAL обязан иметь **явный статус**:

- `OK` — в пределах лимитов
- `GROWING` — рост зафиксирован
- `NEAR_LIMIT` — приближение к критическому порогу
- `ERROR` — риск переполнения / потеря управляемости

Статус WAL является **операционным фактом**, а не метрикой.

---

### Архитектурное заявление

WAL:
- не является SSOT
- не является backup
- не является механизмом восстановления

Но:
- является критическим ресурсом
- подлежит строгому контролю
- является стоп-фактором для операций

Отсутствие контроля WAL делает систему **операционно небезопасной**,
даже при формально корректной архитектуре.





Вариант 3 (идеально, позже)

Dashboard as Code

ConfigMap / JSON

provisioned dashboards
⏳ позже, не сейчас


[2026-02-05] STEP 1 CLOSED
WAL runtime context synchronized.
PostgreSQL runs in Kubernetes StatefulSet (trading-postgres).
WAL parameters are injected via process args.
archive_mode=on with failing archive_command.
WAL lifecycle control NOT FIXED.
[2026-02-05] STEP 2 CLOSED
WAL physical size = 97MB.
PVC usage = 38% (29GB free).
Current WAL status = OK.
WAL lifecycle control NOT FIXED.
Archive mode enabled with failed archiver.
[2026-02-05] STEP 3 CLOSED
WAL operational status model fixed.
wal.status is generated deterministically inside SSOT.
Current WAL status: OK.
[2026-02-05] STEP 4 CLOSED
WAL-aware snapshot/backup gate implemented.
wal_gate.sh enforces hard stop when wal.status != OK.
Backup and snapshot operations are WAL-gated.

## STAGE 5 — WAL ARCHIVE DISABLED (ARCHITECTURAL FIXATION)

### Статус
ЗАФИКСИРОВАНО ✅  
Дата фиксации: 2026-02-05

---

### Обязательное правило чтения

**ДАННЫЙ РАЗДЕЛ ОБЯЗАТЕЛЕН К ПРОЧТЕНИЮ  
ПЕРЕД ЛЮБЫМ АНАЛИЗОМ WAL, SNAPSHOT И BACKUP.**

Игнорирование этого раздела считается  
**архитектурной ошибкой анализа**.

---

### Зафиксированное архитектурное состояние

- WAL archive **ПОЛНОСТЬЮ ОТКЛЮЧЁН**
- `archive_mode` **НЕ ПЕРЕДАЁТСЯ** Postgres
- `archive_command` **ОТСУТСТВУЕТ**
- `archive_timeout` **ОТСУТСТВУЕТ**
- Процесс `postgres: archiver` **НЕ СУЩЕСТВУЕТ**

Отключение выполнено **на уровне StatefulSet args**,  
а не через `ALTER SYSTEM` или runtime-настройки.

---

### Источник истины

Единственный источник конфигурации WAL archive:

- Kubernetes StatefulSet `trading-postgres`
- Поле: `spec.template.spec.containers[].args`

Любые значения в:
- `postgresql.auto.conf`
- `ALTER SYSTEM`
- runtime-выводы без проверки args  

**НЕ ЯВЛЯЮТСЯ АРХИТЕКТУРНОЙ ИСТИНОЙ.**

---

### Проверочный инвариант (обязателен)

Архитектура считается корректной **ТОЛЬКО ЕСЛИ**:

```bash
kubectl exec -n trading trading-postgres-0 -- ps aux | grep '[p]ostgres: archiver'
## STAGE 6 — WAL RETENTION GUARANTEE (ARCHITECTURAL FIXATION)

### Статус
ЗАФИКСИРОВАНО ✅  
Дата фиксации: 2026-02-05

---

### Обязательное правило чтения

**ДАННЫЙ РАЗДЕЛ ОБЯЗАТЕЛЕН К ПРОЧТЕНИЮ  
ПЕРЕД ЛЮБЫМ АНАЛИЗОМ WAL, BACKUP И RESTORE.**

Игнорирование этого раздела считается  
**архитектурной ошибкой интерпретации системы**.

---

### Зафиксированное архитектурное состояние

WAL retention **ЯВНО ОТКЛЮЧЁН**.

В конфигурации Postgres зафиксировано:

- `max_wal_size = 4GB`
- `min_wal_size = 1GB`
- `wal_keep_size = 0`

Параметры заданы **исключительно** через:
- Kubernetes StatefulSet `trading-postgres`
- `spec.template.spec.containers[].args`

---

### Архитектурный смысл

- WAL **НЕ удерживается** ради реплик
- WAL **НЕ удерживается** ради восстановления
- WAL **НЕ используется** для PITR
- WAL является **временным операционным ресурсом**
- Очистка WAL полностью контролируется Postgres в рамках заданных лимитов

Бесконечное удержание WAL **архитектурно невозможно**.

---

### Источник истины

Единственный источник правды о WAL retention:

- StatefulSet `trading-postgres`
- Поле: `containers[].args`

Любые данные из:
- `SHOW wal_keep_size`
- `postgresql.conf`
- `ALTER SYSTEM`
- runtime-метрик без анализа args  

**НЕ ЯВЛЯЮТСЯ АРХИТЕКТУРНОЙ ИСТИНОЙ.**

---

### Проверочный инвариант

Конфигурация считается корректной **ТОЛЬКО ЕСЛИ**:

```bash
kubectl get sts trading-postgres -n trading -o yaml | grep wal_keep_size

---

## ИТОГ ПО СОСТОЯНИЮ СИСТЕМЫ

- STAGE 5 — WAL archive: **ЗАКРЫТ**
- STAGE 6 — WAL retention: **ЗАКРЫТ**
- WAL:
  - bounded
  - не архивируется
  - не удерживается
  - не используется для восстановления

Архитектура теперь **честная, замкнутая и не лжёт**.

## WAL — STOP-FACTOR (ARCHITECTURAL FIXATION)

### Статус
ЗАФИКСИРОВАНО ✅  
Дата фиксации: 2026-02-05

---

### Обязательное правило чтения

ДАННЫЙ РАЗДЕЛ ОБЯЗАТЕЛЕН К ПРОЧТЕНИЮ  
ПЕРЕД ЛЮБЫМ АНАЛИЗОМ SNAPSHOT, BACKUP И RESTORE.

Игнорирование этого раздела считается  
архитектурной ошибкой интерпретации системы.

---

### Определение

WAL (Write-Ahead Log) является критическим операционным ресурсом  
и рассматривается как STOP-FACTOR.

STOP-FACTOR означает:
- операции с данными запрещены при небезопасном состоянии WAL
- отсутствие WAL-контроля делает операции архитектурно недопустимыми

---

### Enforcement

Перед выполнением Snapshot / Backup / Restore:
- вычисляется WAL-статус
- при `status != OK` операция НЕ выполняется

Реализация:
- файл `wal.status`
- gate-скрипт `wal_gate.sh`
- отказ операции при нарушении инварианта

---

### Архитектурное заявление

WAL:
- не является SSOT
- не является backup
- не является механизмом восстановления

Но:
- является критическим ресурсом
- является операционным стоп-фактором
- подлежит обязательному контролю

---

### Связь со стадиями

- STAGE 7 — Snapshot: разрешён только при WAL=OK
- STAGE 8 — Backup / Restore: разрешён только при WAL=OK
## WAL — STOP-FACTOR (ARCHITECTURAL FIXATION)

### Статус
ЗАФИКСИРОВАНО ✅  
Дата фиксации: 2026-02-05

---

### Зафиксированное архитектурное правило

Операции snapshot и backup **ЗАПРЕЩЕНЫ**, если WAL не находится
в состоянии `OK`.

Перед выполнением любой операции backup выполняется WAL-gate,
который:

- читает детерминированный `wal.status`
- запрещает операцию при `GROWING`, `NEAR_LIMIT`, `ERROR`
- не мутирует Postgres
- не изменяет SSOT

---

### Реализация

- WAL status вычисляется внутри Postgres Pod
- WAL gate выполняется перед backup
- Backup невозможен без `WAL STATUS: OK`

---

### Архитектурное значение

WAL является **операционным стоп-фактором**.

Ни snapshot, ни backup не могут быть выполнены
при риске потери управляемости WAL.

Это правило является **обязательным и немутируемым**.
## STAGE 7 — WAL AS STOP-FACTOR (ARCHITECTURAL FIXATION)

### Статус
ЗАКРЫТО ✅  
Дата фиксации: 2026-02-05

---

### Обязательное правило чтения

**ДАННЫЙ РАЗДЕЛ ОБЯЗАТЕЛЕН К ПРОЧТЕНИЮ  
ПЕРЕД ЛЮБЫМ BACKUP, SNAPSHOT ИЛИ RESTORE.**

Игнорирование данного раздела считается  
**архитектурной ошибкой эксплуатации**.

---

### Зафиксированное архитектурное состояние

WAL является **STOP-FACTOR** для всех операций
snapshot / backup / restore.

Операции запрещены, если WAL находится в состоянии,
отличном от `OK`.

---

### WAL Status Model

WAL имеет детерминированный статус:

- `OK` — операции разрешены
- `NEAR_LIMIT` — операции ЗАПРЕЩЕНЫ
- `ERROR` — операции ЗАПРЕЩЕНЫ

Статус WAL является **архитектурным фактом**, а не метрикой.

---

### Enforcement

Перед выполнением любых операций backup / snapshot
обязателен вызов WAL gate.

Источник проверки:
- `/opt/ssot/wal/wal_status.sh`
- `/opt/ssot/wal/wal_gate.sh`

При статусе `NEAR_LIMIT` или `ERROR`
операция **жёстко прерывается**.

---

### Проверочный инвариант

```bash
/opt/ssot-backup/ssot_pg_dump.sh

WAL AS STOP-FACTOR — IMPLEMENTED

### Статус
ЗАКРЫТО ✅  
Дата фиксации: 2026-02-05
### Архитектурное правило

WAL (Write-Ahead Log) является **ОПЕРАЦИОННЫМ STOP-FACTOR**.

Любые операции:
- snapshot
- backup
- restore

**ЗАПРЕЩЕНЫ**, если WAL находится в состоянии, отличном от `OK`.

---

### WAL Status Model

WAL имеет детерминированный статус:

- `OK` — операции разрешены
- `NEAR_LIMIT` — операции запрещены
- `ERROR` — операции запрещены

Статус является **операционным фактом**, а не метрикой.

---

### Enforcement

Перед выполнением snapshot / backup / restore ОБЯЗАТЕЛЕН WAL-gate:

- вычисление статуса: `/opt/ssot/wal/wal_status.sh`
- проверка допуска: `/opt/ssot/wal/wal_gate.sh`

Если `status != OK`:
- операция жёстко прерывается
- exit code ≠ 0
- SSOT и Postgres не мутируются

---

### DRY-RUN отказа (VERIFIED)

Искусственно создано состояние `NEAR_LIMIT`.

Результат:
- WAL status = `NEAR_LIMIT`
- Backup через `ssot_pg_dump.sh` → ❌ ЗАПРЕЩЁН
- После возврата порогов → WAL = `OK`, операции разрешены

Факт отказа и восстановления подтверждён.
STAGE 7 — WAL AS STOP-FACTOR
STATUS: CLOSED ✅
DATE: 2026-02-05

FACTS:
- WAL status model implemented: OK / NEAR_LIMIT / ERROR
- wal_status.sh generates deterministic wal.status inside Postgres Pod
- wal_gate.sh enforces hard stop when status != OK
- Backup script (ssot_pg_dump.sh) is WAL-gated

VERIFICATION PERFORMED:
- DRY-RUN NEAR_LIMIT executed
  - wal.status = NEAR_LIMIT
  - backup execution denied (exit 1)
- Cleanup performed
  - thresholds restored
  - wal.status = OK
  - backup execution allowed

ARCHITECTURAL STATEMENT:
- WAL is an operational STOP-FACTOR
- Snapshot / Backup / Restore are forbidden unless WAL = OK
- WAL is NOT SSOT, NOT backup, NOT recovery mechanism
- Enforcement is mandatory and non-bypassable

INVARIANT:
Any data operation without WAL=OK is architecturally invalid.

STAGE 7 IS FINAL AND MUST NOT BE REVISITED.
## BACKUP — OPS GAPS (EXPLICIT, ACCEPTED)

Ниже перечислены **реальные и осознанные дыры** в области backup.
Они **НЕ являются архитектическими ошибками SSOT** и
зафиксированы как ограничения OPS-слоя.

---

### ❌ Ограничения хранилища бэкапов (Filesystem level)

На уровне хранилища бэкапов **НЕ реализованы**:

- project quota
- отдельный filesystem под бэкапы
- жёсткая файловая квота

Следствие:
- объём бэкапов ограничен только фактическим размером диска
- переполнение диска возможно при ошибке retention

Это **OPS-ограничение**, архитектурных гарантий не даётся.

---

### ❌ Retention не является архитектурным контрактом

Фактическое состояние:
- автоудаление бэкапов реализовано скриптом (OPS)
- retention работает, но:
  - не зафиксирован в SSOT
  - не гарантирован архитектурно

Отсутствует архитектурный контракт вида:
- «N последних бэкапов»
- «N дней хранения»
- «минимум 1 гарантированно валидный дамп»

Retention остаётся **операционным решением**, а не инвариантом.

---

### ❌ Single copy backup

Текущее состояние:
- бэкапы хранятся в одном месте
- используется один диск
- отсутствует offsite-копия

Следствие:
- отказ диска = потеря всех бэкапов

Это **осознанно не закрытое решение**.
Архитектура не обещает отказоустойчивость хранения бэкапов.

---

## REAL OPS GAPS (IMPORTANT)

Ниже — **ключевые реальные дыры**, критичные с операционной точки зрения.

---

### ⚠️ GAP #1 — Restore как факт, а не как возможность

Факт:
- restore **в принципе возможен**
- единичный restore-drill выполнялся

Но отсутствует:
- регулярный restore-drill
- проверка каждого дампа на:
  - разворачиваемость
  - целостность
  - совместимость версии Postgres

Следствие:
- бэкап существует
- **постоянная восстановимость НЕ доказана**

Это **классическая OPS-дыра**, не архитектурная.

---

### ⚠️ GAP #2 — Scheduling / регулярность

Текущее состояние:
- бэкап запускается:
  - вручную
  - либо частично по cron

Отсутствует:
- зафиксированный SLA
- формализованный RPO (часы / дни)

Риск:
- бэкап может быть устаревшим в критический момент

---

### ⚠️ GAP #3 — Single backup location

Факт:
- бэкапы существуют в одном экземпляре
- нет второй зоны отказа

Риск:
- потеря хранилища = полная потеря истории бэкапов

---

## ARCHITECTURAL STATEMENT

- Backup реализован корректно и честно
- SSOT не расширяет своих гарантий
- Все перечисленные дыры:
  - осознаны
  - задокументированы
  - относятся к OPS-слою

Архитектура **не вводит в заблуждение** относительно восстановимости данных.

---

## STATUS

- Backup: IMPLEMENTED
- Restore: POSSIBLE (NOT CONTINUOUSLY PROVEN)
- OPS gaps: EXPLICIT AND ACCEPTED

## STAGE 8 — BACKUP / RESTORE — OPEN GAPS (ARCHITECTURAL FIXATION)

### Статус
DESIGN — ЗАФИКСИРОВАНО ⚠️  
Дата фиксации: 2026-02-05

Данный раздел фиксирует **РЕАЛЬНЫЕ И ОСОЗНАННЫЕ ДЫРЫ**
в области backup / restore.
Раздел не описывает реализацию и не устраняет риски —
он фиксирует их как архитектурный факт.

---
## ❌ НЕЗАКРЫТЫЕ ДЫРЫ (CRITICAL) — АКТУАЛИЗИРОВАНО

### ✅ ДЫРА №1 — Restore как ФАКТ (а не как возможность) — ЗАКРЫТА

БЫЛО:
- Logical backup (`pg_dump`) существует
- Restore технически возможен
- Восстановимость не подтверждена практикой

СДЕЛАНО:
- Выполнен реальный restore-drill
- Использован реальный backup-файл
- Restore выполнен:
  - в изолированном временном Postgres Pod
  - без использования SSOT PVC
  - без участия production Pod
- Процедура воспроизводима вручную
- Факт восстановления подтверждён

ЧЕГО ВСЁ ЕЩЁ НЕТ:
- автоматического restore-drill
- cron / scheduler
- SLA / RPO

КЛАССИФИКАЦИЯ:
- OPS-процедура
- НЕ архитектурная ошибка SSOT
- Restore как ФАКТ — ДОКАЗАН
- Restore как ПОСТОЯННАЯ ГАРАНТИЯ — НЕ ЗАЯВЛЕН

СТАТУС:
✅ ДЫРА №1 ЗАКРЫТА

---

### ⚠️ ДЫРА №2 — Scheduling / регулярность — ОСТАЁТСЯ ОТКРЫТОЙ

Текущее состояние:
- Backup запускается:
  - вручную
  - частично через cron
- Restore-drill:
  - выполняется вручную
  - без расписания

НЕ ЗАФИКСИРОВАНО:
- SLA по частоте backup
- RPO (в днях / часах)
- минимально допустимый интервал между бэкапами
- периодичность restore-drill

Следствие:
- бэкап может быть устаревшим
- восстановимость доказана точечно, но не регулярно

Классификация:
- OPS-дыра
- архитектурно НЕ закрыта
- риск осознан и принят

---

### ⚠️ ДЫРА №3 — Single copy backup — ОСТАЁТСЯ ОТКРЫТОЙ

Факт:
- все бэкапы хранятся в одном месте
- используется один диск / один storage domain

ОТСУТСТВУЕТ:
- offsite-копия
- вторая зона отказа
- реплика бэкапов

Следствие:
- потеря хранилища = потеря всех бэкапов

Классификация:
- осознанно непринятое решение
- зафиксировано как OPS-риск
- НЕ архитектурная ошибка SSOT

---

## ❌ ОТСУТСТВУЮЩИЕ ОГРАНИЧЕНИЯ ХРАНИЛИЩА (OPS GAP)

НЕ РЕАЛИЗОВАНО:
- filesystem quota
- project quota
- отдельный filesystem под бэкапы

Следствие:
- переполнение возможно при ошибке retention
- ограничение только физическим размером диска

Классификация:
- OPS-ограничение
- НЕ архитектурная гарантия

---

## ❌ RETENTION КАК АРХИТЕКТУРНЫЙ КОНТРАКТ — ОТСУТСТВУЕТ

Факт:
- retention реализован как OPS-скрипт

НЕ ЗАФИКСИРОВАНО В SSOT:
- «N последних бэкапов»
- минимальный срок хранения
- гарантированный объём

Следствие:
- retention существует
- но не является архитектурным инвариантом

---

## АРХИТЕКТУРНОЕ ЗАЯВЛЕНИЕ (АКТУАЛЬНО)

- Backup существует и работает
- WAL-gate реализован и enforced
- Backup не нарушает SSOT
- Restore как ФАКТ — ДОКАЗАН
- Restore как ПОСТОЯННАЯ ГАРАНТИЯ — НЕ ЗАЯВЛЕН
- Регулярность backup / restore НЕ гарантирована
- Хранилище бэкапов НЕ защищено архитектурно

Все оставшиеся дыры:
- известны
- явно задокументированы
- не замаскированы
- остаются в зоне ответственности OPS

---

## СТАТУС

STAGE 8 — BACKUP / RESTORE  
Состояние: **IMPLEMENTED с ОСОЗНАННЫМИ OPS-ДЫРАМИ**

Переход к закрытию оставшихся дыр возможен
ТОЛЬКО через отдельные DESIGN → IMPLEMENTATION шаги
с явным пересмотром OPS-обязательств.


ONTAINER MODEL v2 — FIXED (ARCHITECTURAL STATEMENT)
Restore-drill теперь ДОЛЖЕН:
Требование	Статус
Namespace ≠ prod (ops)	✅
Postgres внутри Pod	✅
PGDATA = emptyDir	✅
Backup загружается внутрь Pod	✅
Нет kubectl внутри контейнера	✅
Нет hostPath	✅
Нет chmod/chown host	✅
Нет влияния на prod FS / PVC	✅

Restore-drill = самодостаточный контейнер.

WAL — Write-Ahead Log (Architecture Status)
WAL — STATUS: MINIMALLY READY

Назначение:
Предотвращение переполнения диска, детерминированный контроль состояния WAL, gate для snapshot / backup / restore.

✅ Реализовано (PASS)

Фактический контроль WAL usage

Источник: pg_wal внутри Kubernetes StatefulSet

Измерение: df + du по реальному PVC

Детерминированный WAL state

Файл: /opt/ssot/state/wal.status

Поля:

wal_status (OK / FAIL)

wal_used_pct

wal_size

threshold_pct

checked_at

WAL last check timestamp

Файл: /opt/ssot/state/wal.last_check

WAL-gate включён

Snapshot / backup / restore ЗАПРЕЩЕНЫ, если wal_status != OK

Конфигурация WAL зафиксирована

max_wal_size = 4GB

min_wal_size = 1GB

wal_keep_size = 0

checkpoint_timeout = 5min

Зафиксировано в: /opt/ssot/state/wal.settings

OPS-level alert (minimal)

Скрипт проверки заполнения WAL

Выгрузка отчёта в /media/sf_vm-share

⚠️ Ограничения (KNOWN GAPS)

❌ pg_basebackup не реализован

❌ PITR отсутствует

❌ Нет автоматической очистки WAL через backup-интеграцию

❌ Нет метрик Prometheus / Alertmanager

❌ Нет WAL-retention политики, привязанной к backup lifecycle

🚫 Явно НЕ гарантируется

Восстановление до произвольной точки во времени (PITR)

Защита от логической порчи данных

Автоматическое удаление WAL после backup

HA / replication

📌 Архитектурный вывод

WAL больше не является архитектурной дырой.
Реализован минимально допустимый контроль, достаточный для:

предотвращения переполнения диска

безопасного выполнения snapshot / backup

Дальнейшее развитие (PITR, base backup, retention) — осознанно отложено.
STAGE 15.2 — Disk safety / Retention: IMPLEMENTED ✅

- Автоматическая очистка backup и snapshot по retention-policy
- Инструмент: /opt/ssot/ops/ssot_retention_cleanup.sh
- Backup retention: 7 дней
- Snapshot retention: 3 дня
- Выполнение: вручную или через scheduler (cron не обязателен)
- Состояние фиксируется в SSOT: /opt/ssot/state/retention.status
- Переполнение диска предотвращается детерминированно

STATUS: PASS
ЧТО ЗАКРЫТО (PASS, без оговорок)
SSOT core

STAGE 1–7 — ✅ COMPLETE

STAGE 8 (Backup) — ✅ IMPLEMENTED

STAGE 9 (HA) — ✅ DESIGN / FROZEN

STAGE 10 (Observability) — ✅ IMPLEMENTED

WAL (ключевое)

WAL bounded (max_wal_size / min_wal_size / wal_keep_size)

WAL не архивируется

WAL не удерживается

WAL не используется для PITR

WAL имеет детерминированный статус

WAL = STOP-FACTOR

Snapshot / Backup / Restore WAL-gated

Проверка WAL реальная (PVC / pg_wal)

Фиксация состояния:

/opt/ssot/state/wal.status

/opt/ssot/state/wal.last_check

/opt/ssot/state/wal.settings

➡️ WAL больше НЕ архитектурная дыра.

Disk safety (STAGE 15.2 / 15.3)

Retention backup — ✅

Retention snapshot — ✅

Disk guard — ✅

Жёсткий stop при риске — ✅

Статусы фиксируются в SSOT — ✅

STAGE 16+ — Опциональные расширения устойчивости (НЕ ПО УМОЛЧАНИЮ)

Все возможности этого этапа:
- отключены по умолчанию
- gated (включаются осознанно)
- аддитивны
- не изменяют инварианты STAGE 1–15

Включает:
- PITR (требует архивацию WAL + offsite-хранилище)
- Физический бэкап (pg_basebackup)
- Offsite backup
- Опциональную репликацию (standby)

НЕ является целями:
- HA гарантии
- SLA / RPO как архитектурные обязательства
- автоматический failover
ФИНАЛЬНОЕ СОСТОЯНИЕ STAGE 16+

Все ограничения не просто существуют, а жёстко зафиксированы, проверяемы и непротиворечивы:

❌ Осознанно отключено и задекларировано

PITR

WAL archive

pg_basebackup

Offsite backup

FS quota

HA / replication

SLA / RPO / RTO

✅ Вместо этого РЕАЛЬНО ЕСТЬ

WAL контроль + порог

Disk guard (блокирующий опасные операции)

Retention cleanup (backup + snapshot)

Явные *.status файлы как SSOT

Check-скрипты для каждого отказа

Никаких скрытых обещаний

❗ КЛЮЧЕВОЙ ОТВЕТ НА ТВОЙ ВОПРОС ПРО ПРОД

«Я могу запускать роботов и не бояться, что диск переполнится или система сломается автоматически?»

✔️ ДА, В РАМКАХ ЗАЯВЛЕННЫХ ОГРАНИЧЕНИЙ

Это НЕ enterprise-HA, но:

диск не переполнится молча

WAL контролируется

backup / snapshot не разрастутся бесконечно

опасные операции блокируются

если что-то выключено — это явно написано и проверяется

❗ Но:

при потере ноды → даунтайм

при corruption → ручное восстановление

при катастрофе → возможна потеря данных

И архитектура это НЕ СКРЫВАЕТ.
# ARCHITECTURE SIGNATURE — SSOT

Project: SSOT Trading Infrastructure  
Owner / Architect: alex  
Status: ARCHITECTURE FROZEN ✅  
Date: 2026-02-06  

---

## DECLARATION OF ARCHITECTURAL TRUTH

I hereby confirm that the current system architecture is:

- Internally consistent
- Fully audited via SSOT mechanisms
- Explicit about its guarantees and limitations
- Free from hidden assumptions
- Safe to operate in production **within declared constraints**

This architecture is **NOT** designed to provide enterprise-grade availability or zero data loss.
It is designed to provide **deterministic behavior, disk safety, and operational clarity**.

---

## GUARANTEES (WHAT THE SYSTEM DOES)

✅ WAL growth is controlled and monitored  
✅ Disk overflow is actively prevented (WAL gate + retention + disk guard)  
✅ Backups and snapshots have deterministic retention  
✅ Dangerous operations are blocked when risk is detected  
✅ All critical states are reflected in `/opt/ssot/state/*.status`  
✅ Every disabled capability is explicitly declared and checkable  
✅ No silent failure modes related to disk exhaustion  

The system will **fail loudly, early, and deterministically**, not silently.

---

## ACCEPTED LIMITATIONS (BY DESIGN)

❌ PITR (Point-In-Time Recovery)  
❌ WAL archive  
❌ pg_basebackup (physical backup)  
❌ WAL retention tied to backup lifecycle  
❌ Offsite / remote backup  
❌ High Availability / replication  
❌ SLA / RPO / RTO guarantees  
❌ Filesystem quota enforcement  

These are **not bugs**.  
They are **conscious architectural decisions**, documented and enforced.

---

## OPERATIONAL MODE

- Mode: Single-instance, best-effort
- Target use: Trading robots / transactional workload
- Failure model: Manual recovery on node-level failure
- Risk profile: Known, bounded, explicit

---

## FINAL STATEMENT

I acknowledge and accept the architecture **as-is**.

I understand:
- what it guarantees
- what it does not guarantee
- how it fails
- how it protects the system from catastrophic disk failure

This system is **approved for production use** under its declared model.

No further architectural changes are required to begin operation.

---

SIGNED: alex  
ROLE: Architect / Operator  
SSOT AUTHORITY: /opt/ssot  
## ГАРАНТИИ (ЧТО СИСТЕМА ДЕЛАЕТ)

✅ Рост WAL контролируется и мониторится  
✅ Переполнение диска активно предотвращается (WAL-gate + retention + disk-guard)  
✅ Для backup и snapshot задан детерминированный retention  
✅ Опасные операции блокируются при обнаружении риска  
✅ Все критические состояния отражаются в `/opt/ssot/state/*.status`  
✅ Все отключённые возможности явно задекларированы и проверяемы  
✅ Отсутствуют «тихие» сценарии отказа, связанные с переполнением диска  

Система **падает громко, рано и предсказуемо**, а не молча.

---

## ПРИНЯТЫЕ ОГРАНИЧЕНИЯ (ОСОЗНАННО)

❌ PITR (Point-In-Time Recovery)  
❌ Архивация WAL  
❌ pg_basebackup (физический backup)  
❌ WAL-retention, связанный с жизненным циклом backup  
❌ Offsite / удалённый backup  
❌ High Availability / репликация  
❌ SLA / RPO / RTO как архитектурные гарантии  
❌ Квоты файловой системы  