-- ==========================================================
-- 阿克苏苹果区块链溯源系统 · 数据库初始化脚本 v2.0
-- 遵循《GB/T 29373-2012 农产品追溯要求 果蔬》标准
-- 技术栈：MySQL 8.0 + Hyperledger Fabric v2.2（国密版）+ IPFS
-- ==========================================================

CREATE DATABASE IF NOT EXISTS agri_trace DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE agri_trace;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 表结构定义
-- ============================================================

-- 1. 用户角色表
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id`            bigint       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `username`      varchar(64)  NOT NULL COMMENT '登录账号',
  `password_hash` varchar(255) NOT NULL COMMENT 'bcrypt密码哈希',
  `real_name`     varchar(64)  NOT NULL COMMENT '真实姓名/企业名称',
  `role`          varchar(32)  NOT NULL COMMENT '角色(admin/farmer/inspector/transporter/retailer/consumer)',
  `phone`         varchar(20)  DEFAULT NULL COMMENT '联系电话',
  `email`         varchar(128) DEFAULT NULL COMMENT '邮箱',
  `avatar`        varchar(512) DEFAULT NULL COMMENT '头像URL',
  `org_name`      varchar(128) DEFAULT NULL COMMENT '所属机构/企业名称',
  `status`        tinyint      NOT NULL DEFAULT 1 COMMENT '账号状态(1:正常 0:禁用)',
  `last_login_at` timestamp    NULL COMMENT '最后登录时间',
  `created_at`    timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户角色表';

-- 2. 验证码表（登录/注册图形验证码）
DROP TABLE IF EXISTS `captchas`;
CREATE TABLE `captchas` (
  `id`         bigint      NOT NULL AUTO_INCREMENT,
  `key`        varchar(64) NOT NULL COMMENT '验证码唯一key',
  `code`       varchar(8)  NOT NULL COMMENT '验证码文本',
  `expired_at` timestamp   NOT NULL COMMENT '过期时间',
  `used`       tinyint     NOT NULL DEFAULT 0 COMMENT '是否已使用',
  `created_at` timestamp   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_key` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='图形验证码表';

-- 3. 农产品批次表
DROP TABLE IF EXISTS `agri_batches`;
CREATE TABLE `agri_batches` (
  `id`           bigint        NOT NULL AUTO_INCREMENT,
  `batch_no`     varchar(64)   NOT NULL COMMENT '溯源批次号(全局唯一)',
  `trace_code`   varchar(32)   NOT NULL COMMENT '溯源码(消费者扫码用)',
  `product_name` varchar(128)  NOT NULL COMMENT '产品名称',
  `product_type` varchar(64)   NOT NULL COMMENT '产品类型',
  `variety`      varchar(64)   DEFAULT NULL COMMENT '品种(如:红富士/冰糖心)',
  `quantity`     decimal(10,2) NOT NULL COMMENT '产品数量',
  `unit`         varchar(16)   NOT NULL COMMENT '计量单位',
  `origin_info`  varchar(255)  NOT NULL COMMENT '产地信息',
  `origin_lat`   decimal(10,7) DEFAULT NULL COMMENT '产地纬度',
  `origin_lng`   decimal(10,7) DEFAULT NULL COMMENT '产地经度',
  `farmer_id`    bigint        NOT NULL COMMENT '关联种植户ID',
  `status`       tinyint       NOT NULL DEFAULT 0 COMMENT '状态(0:种植中 1:已采收 2:已质检 3:运输中 4:已上架 5:已售出)',
  `cert_no`      varchar(64)   DEFAULT NULL COMMENT '电子合格证编号',
  `cover_image`  varchar(512)  DEFAULT NULL COMMENT '批次封面图',
  `remark`       varchar(512)  DEFAULT NULL COMMENT '备注',
  `created_at`   timestamp     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`   timestamp     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_batch_no` (`batch_no`),
  UNIQUE KEY `uk_trace_code` (`trace_code`),
  KEY `idx_farmer_id` (`farmer_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='农产品批次表';

-- 4. 种植记录表
DROP TABLE IF EXISTS `planting_records`;
CREATE TABLE `planting_records` (
  `id`              bigint        NOT NULL AUTO_INCREMENT,
  `batch_id`        bigint        NOT NULL COMMENT '关联批次ID',
  `farmer_id`       bigint        NOT NULL COMMENT '种植户ID',
  `field_name`      varchar(128)  NOT NULL COMMENT '地块名称',
  `field_area`      decimal(10,2) DEFAULT NULL COMMENT '种植面积(亩)',
  `field_lat`       decimal(10,7) DEFAULT NULL COMMENT '地块纬度',
  `field_lng`       decimal(10,7) DEFAULT NULL COMMENT '地块经度',
  `plant_date`      date          NOT NULL COMMENT '种植日期',
  `expected_harvest`date          DEFAULT NULL COMMENT '预计采收日期',
  `seed_variety`    varchar(64)   DEFAULT NULL COMMENT '种苗品种',
  `seed_source`     varchar(128)  DEFAULT NULL COMMENT '种苗来源',
  `fertilizer_type` varchar(128)  DEFAULT NULL COMMENT '施肥类型',
  `fertilizer_date` date          DEFAULT NULL COMMENT '最近施肥日期',
  `irrigation_type` varchar(64)   DEFAULT NULL COMMENT '灌溉方式',
  `irrigation_date` date          DEFAULT NULL COMMENT '最近灌溉日期',
  `pesticide_type`  varchar(128)  DEFAULT NULL COMMENT '农药类型(无/有机/生物)',
  `weeding_date`    date          DEFAULT NULL COMMENT '最近除草日期',
  `soil_ph`         varchar(16)   DEFAULT NULL COMMENT '土壤pH值',
  `temperature`     varchar(16)   DEFAULT NULL COMMENT '环境温度',
  `humidity`        varchar(16)   DEFAULT NULL COMMENT '环境湿度',
  `images`          json          DEFAULT NULL COMMENT '现场图片URL列表',
  `tx_hash`         varchar(128)  DEFAULT NULL COMMENT '区块链交易哈希',
  `block_height`    bigint        DEFAULT NULL COMMENT '区块高度',
  `created_at`      timestamp     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      timestamp     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_batch_id` (`batch_id`),
  KEY `idx_farmer_id` (`farmer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='种植记录表';

-- 5. 采收记录表
DROP TABLE IF EXISTS `harvest_records`;
CREATE TABLE `harvest_records` (
  `id`             bigint        NOT NULL AUTO_INCREMENT,
  `batch_id`       bigint        NOT NULL,
  `operator_id`    bigint        NOT NULL COMMENT '操作人ID',
  `harvest_date`   datetime      NOT NULL COMMENT '采收时间',
  `harvest_method` varchar(64)   DEFAULT NULL COMMENT '采收方式(人工/机械)',
  `actual_quantity`decimal(10,2) NOT NULL COMMENT '实际采收量(kg)',
  `weather`        varchar(32)   DEFAULT NULL COMMENT '天气情况',
  `sugar_content`  varchar(16)   DEFAULT NULL COMMENT '糖度(%)',
  `hardness`       varchar(16)   DEFAULT NULL COMMENT '硬度',
  `location`       varchar(255)  NOT NULL COMMENT '采收地点',
  `lat`            decimal(10,7) DEFAULT NULL,
  `lng`            decimal(10,7) DEFAULT NULL,
  `images`         json          DEFAULT NULL COMMENT '现场图片URL列表',
  `tx_hash`        varchar(128)  DEFAULT NULL,
  `block_height`   bigint        DEFAULT NULL,
  `created_at`     timestamp     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_batch_id` (`batch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='采收记录表';

-- 6. 加工记录表
DROP TABLE IF EXISTS `processing_records`;
CREATE TABLE `processing_records` (
  `id`              bigint       NOT NULL AUTO_INCREMENT,
  `batch_id`        bigint       NOT NULL,
  `operator_id`     bigint       NOT NULL COMMENT '操作人ID',
  `operator_phone`  varchar(20)  DEFAULT NULL COMMENT '操作人电话',
  `process_type`    varchar(64)  NOT NULL COMMENT '加工类型(cleaning:清洗 drying:烘干 grading:分级 packing:包装)',
  `process_time`    datetime     NOT NULL COMMENT '加工时间',
  `facility_name`   varchar(128) NOT NULL COMMENT '加工设施名称',
  `facility_addr`   varchar(255) DEFAULT NULL COMMENT '设施地址',
  `facility_lat`    decimal(10,7) DEFAULT NULL,
  `facility_lng`    decimal(10,7) DEFAULT NULL,
  `input_quantity`  decimal(10,2) DEFAULT NULL COMMENT '投入量(kg)',
  `output_quantity` decimal(10,2) DEFAULT NULL COMMENT '产出量(kg)',
  `pack_spec`       varchar(64)  DEFAULT NULL COMMENT '包装规格(如:5kg/箱)',
  `pack_material`   varchar(64)  DEFAULT NULL COMMENT '包装材料',
  `total_boxes`     int          DEFAULT NULL COMMENT '总箱数',
  `standard_no`     varchar(64)  DEFAULT NULL COMMENT '执行标准编号',
  `images`          json         DEFAULT NULL COMMENT '现场图片URL列表',
  `tx_hash`         varchar(128) DEFAULT NULL,
  `block_height`    bigint       DEFAULT NULL,
  `created_at`      timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_batch_id` (`batch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='加工记录表';

-- 7. 质检记录表
DROP TABLE IF EXISTS `inspection_records`;
CREATE TABLE `inspection_records` (
  `id`                bigint       NOT NULL AUTO_INCREMENT,
  `batch_id`          bigint       NOT NULL,
  `inspector_id`      bigint       NOT NULL COMMENT '质检员ID',
  `inspect_time`      datetime     NOT NULL COMMENT '质检时间',
  `inspect_org`       varchar(128) NOT NULL COMMENT '质检机构',
  `inspect_addr`      varchar(255) DEFAULT NULL COMMENT '质检地址',
  `cert_no`           varchar(64)  DEFAULT NULL COMMENT '检验报告编号',
  `pesticide_result`  varchar(16)  NOT NULL DEFAULT '合格' COMMENT '农药残留检测',
  `heavy_metal_result`varchar(16)  NOT NULL DEFAULT '合格' COMMENT '重金属检测',
  `microbe_result`    varchar(16)  NOT NULL DEFAULT '合格' COMMENT '微生物检测',
  `appearance_grade`  varchar(16)  DEFAULT NULL COMMENT '外观等级(优/良/合格)',
  `overall_result`    varchar(16)  NOT NULL DEFAULT '合格' COMMENT '综合结论',
  `report_url`        varchar(512) DEFAULT NULL COMMENT '检测报告文件URL',
  `images`            json         DEFAULT NULL COMMENT '现场图片URL列表',
  `tx_hash`           varchar(128) DEFAULT NULL,
  `block_height`      bigint       DEFAULT NULL,
  `created_at`        timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_batch_id` (`batch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='质检记录表';

-- 8. 物流追踪表
DROP TABLE IF EXISTS `logistics_records`;
CREATE TABLE `logistics_records` (
  `id`              bigint        NOT NULL AUTO_INCREMENT,
  `batch_id`        bigint        NOT NULL,
  `operator_id`     bigint        NOT NULL COMMENT '物流操作人ID',
  `transport_type`  varchar(32)   NOT NULL COMMENT '运输方式(road:公路 rail:铁路 air:航空)',
  `vehicle_no`      varchar(32)   DEFAULT NULL COMMENT '车牌号/运单号',
  `driver_name`     varchar(32)   DEFAULT NULL COMMENT '司机姓名',
  `driver_phone`    varchar(20)   DEFAULT NULL COMMENT '司机电话',
  `depart_time`     datetime      NOT NULL COMMENT '发车时间',
  `arrive_time`     datetime      DEFAULT NULL COMMENT '到达时间',
  `depart_location` varchar(255)  NOT NULL COMMENT '出发地',
  `depart_lat`      decimal(10,7) DEFAULT NULL,
  `depart_lng`      decimal(10,7) DEFAULT NULL,
  `arrive_location` varchar(255)  NOT NULL COMMENT '目的地',
  `arrive_lat`      decimal(10,7) DEFAULT NULL,
  `arrive_lng`      decimal(10,7) DEFAULT NULL,
  `temp_control`    varchar(32)   DEFAULT NULL COMMENT '温控要求(如:0-4°C)',
  `current_temp`    varchar(16)   DEFAULT NULL COMMENT '实时温度',
  `status`          varchar(16)   NOT NULL DEFAULT 'in_transit' COMMENT '状态(in_transit/arrived)',
  `images`          json          DEFAULT NULL COMMENT '现场图片URL列表',
  `tx_hash`         varchar(128)  DEFAULT NULL,
  `block_height`    bigint        DEFAULT NULL,
  `created_at`      timestamp     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_batch_id` (`batch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='物流追踪表';

-- 9. 电子合格证表
DROP TABLE IF EXISTS `certificates`;
CREATE TABLE `certificates` (
  `id`             bigint       NOT NULL AUTO_INCREMENT,
  `batch_id`       bigint       NOT NULL UNIQUE COMMENT '关联批次(一批次一证)',
  `cert_no`        varchar(64)  NOT NULL UNIQUE COMMENT '合格证编号',
  `product_name`   varchar(128) NOT NULL COMMENT '产品名称',
  `producer_name`  varchar(128) NOT NULL COMMENT '生产者名称',
  `producer_addr`  varchar(255) NOT NULL COMMENT '生产者地址',
  `producer_phone` varchar(20)  DEFAULT NULL COMMENT '生产者电话',
  `quantity`       varchar(64)  NOT NULL COMMENT '数量规格',
  `issue_date`     date         NOT NULL COMMENT '出具日期',
  `valid_until`    date         DEFAULT NULL COMMENT '有效期至',
  `issue_org`      varchar(128) NOT NULL COMMENT '出具机构',
  `issue_org_seal` varchar(512) DEFAULT NULL COMMENT '机构印章图片URL',
  `pesticide_ok`   tinyint      NOT NULL DEFAULT 1 COMMENT '农药残留合格',
  `heavy_metal_ok` tinyint      NOT NULL DEFAULT 1 COMMENT '重金属合格',
  `microbe_ok`     tinyint      NOT NULL DEFAULT 1 COMMENT '微生物合格',
  `qr_code_url`    varchar(512) DEFAULT NULL COMMENT '二维码图片URL',
  `pdf_url`        varchar(512) DEFAULT NULL COMMENT '合格证PDF URL',
  `tx_hash`        varchar(128) DEFAULT NULL COMMENT '上链哈希',
  `created_at`     timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_batch_id` (`batch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='电子合格证表';

-- 10. 溯源节点流转表（通用，兼容旧版）
DROP TABLE IF EXISTS `trace_records`;
CREATE TABLE `trace_records` (
  `id`             bigint       NOT NULL AUTO_INCREMENT,
  `batch_id`       bigint       NOT NULL,
  `node_type`      varchar(32)  NOT NULL COMMENT '节点类型(planting/harvesting/processing/inspecting/transporting/retailing)',
  `operator_id`    bigint       NOT NULL,
  `operation_time` datetime     NOT NULL,
  `location`       varchar(255) NOT NULL,
  `env_data`       json         DEFAULT NULL COMMENT '扩展业务数据',
  `tx_hash`        varchar(128) DEFAULT NULL COMMENT '区块链交易哈希(SM3)',
  `block_height`   bigint       DEFAULT NULL,
  `created_at`     timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_batch_id` (`batch_id`),
  KEY `idx_node_type` (`node_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='溯源节点流转表';

-- 11. IPFS文件关联表
DROP TABLE IF EXISTS `ipfs_files`;
CREATE TABLE `ipfs_files` (
  `id`         bigint       NOT NULL AUTO_INCREMENT,
  `record_id`  bigint       NOT NULL COMMENT '关联记录ID',
  `record_type`varchar(32)  NOT NULL DEFAULT 'trace' COMMENT '记录类型(trace/planting/harvest/processing/inspection/logistics)',
  `file_name`  varchar(128) NOT NULL,
  `file_type`  varchar(32)  NOT NULL COMMENT '文件类型(image/report/video)',
  `cid`        varchar(128) NOT NULL COMMENT 'IPFS CID',
  `file_url`   varchar(512) DEFAULT NULL COMMENT '可访问URL',
  `created_at` timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_record_id` (`record_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='IPFS文件关联表';

-- 12. 操作日志表
DROP TABLE IF EXISTS `operation_logs`;
CREATE TABLE `operation_logs` (
  `id`          bigint       NOT NULL AUTO_INCREMENT,
  `user_id`     bigint       DEFAULT NULL COMMENT '操作用户ID',
  `username`    varchar(64)  DEFAULT NULL,
  `action`      varchar(64)  NOT NULL COMMENT '操作动作',
  `module`      varchar(32)  NOT NULL COMMENT '模块(auth/batch/planting/logistics/cert等)',
  `target_id`   bigint       DEFAULT NULL COMMENT '操作对象ID',
  `detail`      varchar(512) DEFAULT NULL COMMENT '操作详情',
  `ip`          varchar(64)  DEFAULT NULL COMMENT '客户端IP',
  `user_agent`  varchar(256) DEFAULT NULL,
  `status`      varchar(16)  NOT NULL DEFAULT 'success' COMMENT '结果(success/fail)',
  `created_at`  timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表';

-- 13. 系统统计快照表（仪表盘数据）
DROP TABLE IF EXISTS `dashboard_stats`;
CREATE TABLE `dashboard_stats` (
  `id`              bigint  NOT NULL AUTO_INCREMENT,
  `stat_date`       date    NOT NULL COMMENT '统计日期',
  `total_batches`   int     NOT NULL DEFAULT 0 COMMENT '累计批次数',
  `total_users`     int     NOT NULL DEFAULT 0 COMMENT '累计用户数',
  `total_visitors`  int     NOT NULL DEFAULT 0 COMMENT '当日访客数',
  `total_queries`   int     NOT NULL DEFAULT 0 COMMENT '当日溯源查询次数',
  `total_tx`        int     NOT NULL DEFAULT 0 COMMENT '当日区块链交易数',
  `total_amount`    decimal(12,2) NOT NULL DEFAULT 0 COMMENT '当日交易金额(万元)',
  `created_at`      timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_stat_date` (`stat_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='仪表盘统计快照表';

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- 模拟数据 INSERT
-- 所有用户密码均为 123456 (bcrypt cost=10)
-- ============================================================

-- 1. 用户数据（10个用户，覆盖所有角色）
INSERT INTO `users` (`id`,`username`,`password_hash`,`real_name`,`role`,`phone`,`email`,`org_name`,`status`) VALUES
(1,'admin',       '$2b$10$kTGq9ZP9T50XT33GRSR9uOR8LsxV2CsZcI3hJmF6gZOlYNgFH2JR2','系统管理员',      'admin',       '13800000000','admin@aksutrace.com',       '阿克苏农产品溯源平台',1),
(2,'farmer_wang', '$2b$10$5oc9AKzK33xAmjaAnf6qoudZkjsZws6b1LOZ5eGUQ0wwbklOStLOG','王建国',          'farmer',      '13901234567','wangjg@farm.com',           '红旗坡农场专业合作社',1),
(3,'farmer_li',   '$2b$10$8l3l3EXSj65ko4DHzn7Zy.eXX2O.do0s2TeOzRQ64ycoiBxo2SqfC','李秀英',          'farmer',      '13812345678','lixiuying@farm.com',        '温宿县苹果种植基地',1),
(4,'inspector_zhang','$2b$10$35kkiiJcIbZndKqHm/ek1u17wVyTQ7odFX6pBP75cMYEUaoq2nTYS','张质检',       'inspector',   '13723456789','zhangqj@aks-agri.gov.cn',   '阿克苏地区农业农村局',1),
(5,'inspector_chen','$2b$10$RRdxP63kTW38lFyaPQd8BucXr7iz60Gr6snTwkUHzf2r.EXDkBxha','陈检测',       'inspector',   '13634567890','chenjianche@lab.com',       '新疆农产品质量检测中心',1),
(6,'transporter_sun','$2b$10$kTGq9ZP9T50XT33GRSR9uOR8LsxV2CsZcI3hJmF6gZOlYNgFH2JR2','孙师傅',      'transporter', '13545678901','sunwuliu@sf-cold.com',      '顺丰冷链物流(新疆)',1),
(7,'transporter_zhou','$2b$10$5oc9AKzK33xAmjaAnf6qoudZkjsZws6b1LOZ5eGUQ0wwbklOStLOG','周运输',     'transporter', '13456789012','zhouwuliu@jd-logistics.com','京东物流(阿克苏站)',1),
(8,'retailer_zhao','$2b$10$8l3l3EXSj65ko4DHzn7Zy.eXX2O.do0s2TeOzRQ64ycoiBxo2SqfC','赵店长',        'retailer',    '13367890123','zhaosc@hema.com',           '盒马鲜生(上海浦东店)',1),
(9,'retailer_wu', '$2b$10$35kkiiJcIbZndKqHm/ek1u17wVyTQ7odFX6pBP75cMYEUaoq2nTYS','吴经理',         'retailer',    '13278901234','wujl@jd-fresh.com',         '京东生鲜(北京旗舰店)',1),
(10,'consumer_test','$2b$10$RRdxP63kTW38lFyaPQd8BucXr7iz60Gr6snTwkUHzf2r.EXDkBxha','测试消费者',   'consumer',    '13189012345','consumer@test.com',         NULL,1);

-- 2. 农产品批次数据（5个批次）
INSERT INTO `agri_batches` (`id`,`batch_no`,`trace_code`,`product_name`,`product_type`,`variety`,`quantity`,`unit`,`origin_info`,`origin_lat`,`origin_lng`,`farmer_id`,`status`,`cert_no`,`cover_image`) VALUES
(1,'BATCH-APPLE-20251025-001','AKS2025100001','阿克苏冰糖心苹果','果蔬类','冰糖心红富士',5000.00,'kg','新疆阿克苏地区温宿县红旗坡农场A区',41.2756830,80.2437560,2,4,'CERT-2025-AKS-001','https://images.unsplash.com/photo-1568702846914-96b305d2aaeb?w=400'),
(2,'BATCH-APPLE-20251101-002','AKS2025100002','阿克苏红富士苹果','果蔬类','红富士',3000.00,'kg','新疆阿克苏地区温宿县苹果示范基地B区',41.2812340,80.2501230,3,4,'CERT-2025-AKS-002','https://images.unsplash.com/photo-1570913149827-d2ac84ab3f9a?w=400'),
(3,'BATCH-APPLE-20251110-003','AKS2025100003','阿克苏糖心苹果礼盒','果蔬类','糖心苹果',1200.00,'箱','新疆阿克苏地区阿克苏市红旗坡镇C区果园',41.2689120,80.2378900,2,3,'CERT-2025-AKS-003','https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400'),
(4,'BATCH-APPLE-20251115-004','AKS2025100004','有机认证富士苹果','果蔬类','有机富士',800.00,'kg','新疆阿克苏地区乌什县有机苹果基地',41.2134560,79.2345670,3,2,'CERT-2025-AKS-004','https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?w=400'),
(5,'BATCH-APPLE-20251120-005','AKS2025100005','阿克苏苹果脆片','加工类','苹果脆片',500.00,'袋','新疆阿克苏地区农产品加工园区',41.1987650,80.2654320,2,1,NULL,'https://images.unsplash.com/photo-1619546813926-a78fa6372cd2?w=400');

-- 3. 种植记录
INSERT INTO `planting_records` (`id`,`batch_id`,`farmer_id`,`field_name`,`field_area`,`field_lat`,`field_lng`,`plant_date`,`expected_harvest`,`seed_variety`,`seed_source`,`fertilizer_type`,`fertilizer_date`,`irrigation_type`,`irrigation_date`,`pesticide_type`,`weeding_date`,`soil_ph`,`temperature`,`humidity`,`images`,`tx_hash`,`block_height`) VALUES
(1,1,2,'红旗坡A区果园',120.50,41.2756830,80.2437560,'2025-04-10','2025-10-25','冰糖心红富士','阿克苏地区农业局认证苗木基地','有机农家肥+复合肥','2025-06-15','滴灌','2025-07-20','生物农药(低毒)','2025-07-10','7.2','18°C','42%','["https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=400","https://images.unsplash.com/photo-1500651230702-0e2d8a49d4ad?w=400"]','0x8b3a4f9e2d1c5b7a6f8e9d0c1b2a3f4e5d6c7b8a9f0e1d2c3b4a5f6e7d8c9b0a',1001),
(2,2,3,'温宿县示范基地B区',85.00,41.2812340,80.2501230,'2025-04-15','2025-10-30','红富士','温宿县农业科技推广站','有机肥+微量元素肥','2025-06-20','漫灌','2025-07-25','无农药','2025-07-15','7.0','17°C','45%','["https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400","https://images.unsplash.com/photo-1530836369250-ef72a3f5cda8?w=400"]','0x9c4b5f0e3d2c6b8a7f9e0d1c2b3a4f5e6d7c8b9a0f1e2d3c4b5a6f7e8d9c0b1a',1002),
(3,3,2,'红旗坡C区精品果园',45.00,41.2689120,80.2378900,'2025-04-08','2025-10-20','糖心苹果','新疆农科院优质苗木','羊粪有机肥','2025-06-10','微喷灌','2025-07-18','零农药','2025-07-08','7.3','19°C','40%','["https://images.unsplash.com/photo-1501004318641-b39e6451bec6?w=400"]','0xa1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2',1003);

-- 4. 采收记录
INSERT INTO `harvest_records` (`id`,`batch_id`,`operator_id`,`harvest_date`,`harvest_method`,`actual_quantity`,`weather`,`sugar_content`,`hardness`,`location`,`lat`,`lng`,`images`,`tx_hash`,`block_height`) VALUES
(1,1,2,'2025-10-25 09:00:00','人工采摘',5120.00,'晴，微风','18.5%','8.2kg/cm²','新疆阿克苏温宿县红旗坡A区果园',41.2756830,80.2437560,'["https://images.unsplash.com/photo-1506484381205-f7945653044d?w=400","https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400"]','0x1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b',1502),
(2,2,3,'2025-10-30 08:30:00','人工+机械辅助',3050.00,'多云','17.8%','7.9kg/cm²','新疆阿克苏温宿县示范基地B区',41.2812340,80.2501230,'["https://images.unsplash.com/photo-1570913149827-d2ac84ab3f9a?w=400"]','0x2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c',1503),
(3,3,2,'2025-10-20 10:00:00','全人工精品采摘',1250.00,'晴','19.2%','8.5kg/cm²','新疆阿克苏红旗坡C区精品果园',41.2689120,80.2378900,'["https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400"]','0x3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d',1504);

-- 5. 加工记录
INSERT INTO `processing_records` (`id`,`batch_id`,`operator_id`,`operator_phone`,`process_type`,`process_time`,`facility_name`,`facility_addr`,`facility_lat`,`facility_lng`,`input_quantity`,`output_quantity`,`pack_spec`,`pack_material`,`total_boxes`,`standard_no`,`images`,`tx_hash`,`block_height`) VALUES
(1,1,2,'13901234567','cleaning','2025-10-26 08:00:00','红旗坡农场清洗车间','新疆阿克苏温宿县红旗坡农场加工区',41.2760000,80.2440000,5120.00,5000.00,NULL,'不适用',NULL,'GB/T 10651-2008','["https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400"]','0x4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e',1600),
(2,1,2,'13901234567','grading','2025-10-26 14:00:00','红旗坡农场分级车间','新疆阿克苏温宿县红旗坡农场加工区',41.2760000,80.2440000,5000.00,4800.00,NULL,'不适用',NULL,'NY/T 1793-2009','["https://images.unsplash.com/photo-1542838132-92c53300491e?w=400"]','0x5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f',1601),
(3,1,2,'13901234567','packing','2025-10-27 09:00:00','红旗坡农场包装车间','新疆阿克苏温宿县红旗坡农场加工区',41.2760000,80.2440000,4800.00,4750.00,'5kg/箱','环保瓦楞纸箱',950,'GB/T 13607-1992','["https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=400","https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=400"]','0x6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a',1602),
(4,2,3,'13812345678','cleaning','2025-10-31 08:00:00','温宿县农产品加工中心','新疆阿克苏温宿县工业园区',41.2815000,80.2505000,3050.00,2980.00,NULL,'不适用',NULL,'GB/T 10651-2008','["https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400"]','0x7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b',1603),
(5,2,3,'13812345678','packing','2025-10-31 14:00:00','温宿县农产品加工中心','新疆阿克苏温宿县工业园区',41.2815000,80.2505000,2980.00,2950.00,'5kg/箱','环保纸箱',590,'GB/T 13607-1992','["https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=400"]','0x8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c',1604);

-- 6. 质检记录
INSERT INTO `inspection_records` (`id`,`batch_id`,`inspector_id`,`inspect_time`,`inspect_org`,`inspect_addr`,`cert_no`,`pesticide_result`,`heavy_metal_result`,`microbe_result`,`appearance_grade`,`overall_result`,`report_url`,`images`,`tx_hash`,`block_height`) VALUES
(1,1,4,'2025-10-28 14:00:00','阿克苏地区农业农村局检测中心','新疆阿克苏市农业大厦3楼','QC-2025-AKS-001','合格','未检出','合格','优级','合格','https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=400','["https://images.unsplash.com/photo-1576086213369-97a306d36557?w=400"]','0x2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c',1588),
(2,2,5,'2025-11-02 10:00:00','新疆农产品质量检测中心','乌鲁木齐市农业路88号','QC-2025-AKS-002','合格','未检出','合格','良级','合格','https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=400','["https://images.unsplash.com/photo-1576086213369-97a306d36557?w=400"]','0x3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d',1590),
(3,3,4,'2025-10-22 14:00:00','阿克苏地区农业农村局检测中心','新疆阿克苏市农业大厦3楼','QC-2025-AKS-003','合格','未检出','合格','优级','合格','https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=400','["https://images.unsplash.com/photo-1576086213369-97a306d36557?w=400"]','0x4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e',1592),
(4,4,5,'2025-11-16 09:00:00','新疆农产品质量检测中心','乌鲁木齐市农业路88号','QC-2025-AKS-004','合格','未检出','合格','优级','合格','https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=400','["https://images.unsplash.com/photo-1576086213369-97a306d36557?w=400"]','0x5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f',1594);

-- 7. 物流记录
INSERT INTO `logistics_records` (`id`,`batch_id`,`operator_id`,`transport_type`,`vehicle_no`,`driver_name`,`driver_phone`,`depart_time`,`arrive_time`,`depart_location`,`depart_lat`,`depart_lng`,`arrive_location`,`arrive_lat`,`arrive_lng`,`temp_control`,`current_temp`,`status`,`images`,`tx_hash`,`block_height`) VALUES
(1,1,6,'road','新A·SF8888','孙师傅','13545678901','2025-11-05 08:00:00','2025-11-08 18:00:00','新疆阿克苏温宿县红旗坡农场',41.2756830,80.2437560,'上海市浦东新区盒马鲜生配送中心',31.2304000,121.4737000,'0~4°C冷链','2.1°C','arrived','["https://images.unsplash.com/photo-1601584115197-04ecc0da31d7?w=400","https://images.unsplash.com/photo-1519003722824-194d4455a60c?w=400"]','0x4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e',1850),
(2,2,7,'road','新B·JD9999','周运输','13456789012','2025-11-08 07:00:00','2025-11-11 20:00:00','新疆阿克苏温宿县示范基地',41.2812340,80.2501230,'北京市朝阳区京东生鲜仓储中心',39.9042000,116.4074000,'0~4°C冷链','1.8°C','arrived','["https://images.unsplash.com/photo-1601584115197-04ecc0da31d7?w=400"]','0x5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f',1851),
(3,3,6,'road','新A·SF7777','孙师傅','13545678901','2025-11-01 09:00:00',NULL,'新疆阿克苏红旗坡C区',41.2689120,80.2378900,'广州市天河区高端生鲜超市',23.1291000,113.2644000,'0~4°C冷链','2.5°C','in_transit','["https://images.unsplash.com/photo-1519003722824-194d4455a60c?w=400"]','0x6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a',1852);

-- 8. 电子合格证
INSERT INTO `certificates` (`id`,`batch_id`,`cert_no`,`product_name`,`producer_name`,`producer_addr`,`producer_phone`,`quantity`,`issue_date`,`valid_until`,`issue_org`,`pesticide_ok`,`heavy_metal_ok`,`microbe_ok`,`tx_hash`) VALUES
(1,1,'CERT-2025-AKS-001','阿克苏冰糖心苹果','红旗坡农场专业合作社(王建国)','新疆阿克苏地区温宿县红旗坡镇农场A区','13901234567','5000kg / 950箱','2025-10-28','2025-12-28','阿克苏地区农业农村局',1,1,1,'0x2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c'),
(2,2,'CERT-2025-AKS-002','阿克苏红富士苹果','温宿县苹果种植基地(李秀英)','新疆阿克苏地区温宿县苹果示范基地B区','13812345678','3000kg / 590箱','2025-11-02','2026-01-02','新疆农产品质量检测中心',1,1,1,'0x3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d'),
(3,3,'CERT-2025-AKS-003','阿克苏糖心苹果礼盒','红旗坡农场专业合作社(王建国)','新疆阿克苏地区温宿县红旗坡镇C区果园','13901234567','1200箱','2025-10-22','2025-12-22','阿克苏地区农业农村局',1,1,1,'0x4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e'),
(4,4,'CERT-2025-AKS-004','有机认证富士苹果','温宿县苹果种植基地(李秀英)','新疆阿克苏地区乌什县有机苹果基地','13812345678','800kg','2025-11-16','2026-01-16','新疆农产品质量检测中心',1,1,1,'0x5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f');

-- 9. 溯源节点流转（兼容旧版）
INSERT INTO `trace_records` (`id`,`batch_id`,`node_type`,`operator_id`,`operation_time`,`location`,`env_data`,`tx_hash`,`block_height`) VALUES
(1,1,'planting',  2,'2025-04-10 10:30:00','新疆阿克苏温宿县红旗坡A区','{"temperature":"18°C","humidity":"42%","soil_ph":"7.2","fertilizer":"有机农家肥","pesticide":"生物农药"}','0x8b3a4f9e2d1c5b7a6f8e9d0c1b2a3f4e5d6c7b8a9f0e1d2c3b4a5f6e7d8c9b0a',1001),
(2,1,'harvesting', 2,'2025-10-25 09:00:00','新疆阿克苏温宿县红旗坡A区','{"weather":"晴","method":"人工采摘","sugar_content":"18.5%","actual_qty":"5120kg"}','0x1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b',1502),
(3,1,'inspecting', 4,'2025-10-28 14:00:00','阿克苏地区农业农村局检测中心','{"pesticide_residue":"合格","heavy_metal":"未检出","appearance":"优级","cert_no":"QC-2025-AKS-001"}','0x2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c',1588),
(4,1,'processing', 2,'2025-10-27 09:00:00','红旗坡农场包装车间','{"process_type":"清洗/分级/包装","pack_spec":"5kg/箱","total_boxes":950}','0x3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d',1605),
(5,1,'transporting',6,'2025-11-05 08:00:00','新疆阿克苏→上海浦东','{"vehicle_no":"新A·SF8888","driver":"孙师傅","temp_control":"0-4°C冷链","dest":"上海市浦东新区"}','0x4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e',1850),
(6,1,'retailing',  8,'2025-11-09 09:00:00','盒马鲜生(上海浦东店)','{"shelf_no":"A-01","storage_temp":"4°C","retail_price":"15.8元/kg","shelf_life":"30天"}','0x5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f',2100);

-- 10. IPFS文件
INSERT INTO `ipfs_files` (`id`,`record_id`,`record_type`,`file_name`,`file_type`,`cid`,`file_url`) VALUES
(1,1,'planting','planting_site_A.jpg','image','QmXoypizjW3WknFiJnKLwHCnL72vedxjQkDDP1mXWo6uco','https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=400'),
(2,1,'inspection','inspection_report_001.pdf','report','QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG','https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=400'),
(3,1,'logistics','transport_vehicle_001.jpg','image','QmZTR5bcpQD7cFgTorxoPcqTEbpZfPz4o6Zq4N7v9E2kQW','https://images.unsplash.com/photo-1601584115197-04ecc0da31d7?w=400'),
(4,2,'planting','planting_site_B.jpg','image','QmT5NvUtoM5nWFfrQdVrFtvgfKFmG7Zp2RCh7PkKZxkL2Z','https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400'),
(5,3,'processing','packing_process.jpg','image','QmPZ9gcCEpqKTo9ikXESmmExKGe4MmCq7JLMbhkidwkZhZ','https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=400');

-- 11. 操作日志
INSERT INTO `operation_logs` (`id`,`user_id`,`username`,`action`,`module`,`target_id`,`detail`,`ip`,`status`) VALUES
(1,2,'farmer_wang','创建批次','batch',1,'创建批次 BATCH-APPLE-20251025-001','192.168.1.101','success'),
(2,2,'farmer_wang','添加种植记录','planting',1,'为批次1添加种植记录','192.168.1.101','success'),
(3,4,'inspector_zhang','添加质检记录','inspection',1,'为批次1出具质检报告 QC-2025-AKS-001','192.168.1.102','success'),
(4,6,'transporter_sun','添加物流记录','logistics',1,'批次1开始运输，目的地上海','192.168.1.103','success'),
(5,1,'admin','查看用户列表','admin',NULL,'管理员查看用户列表','192.168.1.100','success'),
(6,8,'retailer_zhao','查询溯源信息','trace',1,'消费者扫码查询 AKS2025100001','192.168.1.200','success'),
(7,2,'farmer_wang','上传图片','planting',1,'上传种植现场图片2张','192.168.1.101','success'),
(8,1,'admin','生成合格证','cert',1,'为批次1生成电子合格证','192.168.1.100','success');

-- 12. 仪表盘统计数据（近30天）
INSERT INTO `dashboard_stats` (`stat_date`,`total_batches`,`total_users`,`total_visitors`,`total_queries`,`total_tx`,`total_amount`) VALUES
('2025-11-01',3,8,156,89,45,12.50),
('2025-11-02',3,8,203,112,67,18.30),
('2025-11-03',4,9,178,98,52,15.60),
('2025-11-04',4,9,234,145,78,22.10),
('2025-11-05',4,9,312,189,103,31.20),
('2025-11-06',4,9,289,167,91,27.80),
('2025-11-07',4,9,198,123,68,19.40),
('2025-11-08',5,10,356,234,128,38.90),
('2025-11-09',5,10,423,289,156,47.60),
('2025-11-10',5,10,389,256,139,42.30),
('2025-11-11',5,10,445,312,172,52.80),
('2025-11-12',5,10,512,378,198,61.20),
('2025-11-13',5,10,478,345,183,56.70),
('2025-11-14',5,10,356,234,128,39.50),
('2025-11-15',5,10,534,412,218,67.40);
