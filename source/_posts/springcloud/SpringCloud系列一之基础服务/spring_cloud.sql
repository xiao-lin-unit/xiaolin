/*
 Navicat Premium Data Transfer

 Source Server         : localhost-mysql8
 Source Server Type    : MySQL
 Source Server Version : 80035 (8.0.35)
 Source Host           : localhost:3306
 Source Schema         : spring_cloud

 Target Server Type    : MySQL
 Target Server Version : 80035 (8.0.35)
 File Encoding         : 65001

 Date: 28/11/2023 19:13:49
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for sys_company
-- ----------------------------
DROP TABLE IF EXISTS `sys_company`;
CREATE TABLE `sys_company`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '公司名',
  `stru_id` int NOT NULL COMMENT '结构主键',
  `phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系电话',
  `email` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `address` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '地址',
  `sort` int NOT NULL COMMENT '排序',
  `deleted` int NOT NULL DEFAULT 0 COMMENT '删除(0:否; 1: 是)',
  `create_time` datetime NULL DEFAULT NULL,
  `creator` int NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `update_user` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_company_stru_id`(`stru_id` ASC) USING BTREE,
  CONSTRAINT `fk_company_stru_id` FOREIGN KEY (`stru_id`) REFERENCES `sys_structure` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '企业' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_company
-- ----------------------------

-- ----------------------------
-- Table structure for sys_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_dept`;
CREATE TABLE `sys_dept`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '部门名称',
  `stru_id` int NOT NULL COMMENT '结构主键',
  `company_id` int NOT NULL COMMENT '企业主键',
  `phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系电话',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态(0: 停用; 1: 正常)',
  `sort` int NOT NULL COMMENT '排序',
  `deleted` int NOT NULL DEFAULT 0 COMMENT '删除(0: 否; 1: 是)',
  `create_time` datetime NULL DEFAULT NULL,
  `creator` int NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `update_user` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_dept_conpany_id`(`company_id` ASC) USING BTREE,
  INDEX `fk_dept_stru_id`(`stru_id` ASC) USING BTREE,
  CONSTRAINT `fk_dept_conpany_id` FOREIGN KEY (`company_id`) REFERENCES `sys_company` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_dept_stru_id` FOREIGN KEY (`stru_id`) REFERENCES `sys_structure` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '部门表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dept
-- ----------------------------

-- ----------------------------
-- Table structure for sys_dict_data
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE `sys_dict_data`  (
  `id` int NOT NULL COMMENT '主键',
  `type_id` int NOT NULL COMMENT '类型主键',
  `parent_id` int NULL DEFAULT NULL COMMENT '父级字典主键',
  `dict_label` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '显示',
  `dict_value` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '值',
  `is_default` int NOT NULL DEFAULT 0 COMMENT '是否作为默认值',
  `sort` int NOT NULL COMMENT '排序',
  `deleted` int NOT NULL DEFAULT 0 COMMENT '删除(0: 否; 1: 是)',
  `create_time` datetime NULL DEFAULT NULL,
  `creator` int NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `update_user` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_dict_type_id`(`parent_id` ASC) USING BTREE,
  CONSTRAINT `fk_dict_type_id` FOREIGN KEY (`parent_id`) REFERENCES `sys_dict_type` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '字典数据' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dict_data
-- ----------------------------

-- ----------------------------
-- Table structure for sys_dict_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '字典类型名称',
  `dict_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '字典类型标记',
  `category` int NOT NULL DEFAULT 0 COMMENT '类别(0: 系统字典; 1: 业务字典)',
  `remark` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `sort` int NOT NULL COMMENT '排序',
  `deleted` int NOT NULL DEFAULT 0 COMMENT '删除(0: 否; 1: 是)',
  `create_time` datetime NULL DEFAULT NULL,
  `creator` int NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `update_user` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '字典类型表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dict_type
-- ----------------------------
INSERT INTO `sys_dict_type` VALUES (-2081353726, '性别', 'sex', 0, '性别字典类型', 1, 0, '2023-11-28 16:19:46', 0, '2023-11-28 16:19:46', 0);

-- ----------------------------
-- Table structure for sys_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_post`;
CREATE TABLE `sys_post`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '岗位名称',
  `code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '岗位编码',
  `status` int NULL DEFAULT NULL COMMENT '岗位状态(0: 停用; 1: 启用)',
  `sort` int NOT NULL COMMENT '排序',
  `deleted` int NOT NULL DEFAULT 0 COMMENT '删除(0: 否; 1: 是)',
  `create_time` datetime NULL DEFAULT NULL,
  `creator` int NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `update_user` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_post
-- ----------------------------

-- ----------------------------
-- Table structure for sys_staff
-- ----------------------------
DROP TABLE IF EXISTS `sys_staff`;
CREATE TABLE `sys_staff`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '姓名',
  `stru_id` int NOT NULL COMMENT '结构主键',
  `dept_id` int NOT NULL COMMENT '部门主键',
  `company_id` int NOT NULL COMMENT '企业主键',
  `email` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手机号',
  `sex` int NULL DEFAULT NULL COMMENT '性别',
  `id_card` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '身份证',
  `address` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '住址',
  `word_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '工号',
  `entry_time` datetime NULL DEFAULT NULL COMMENT '入职时间',
  `depart_time` datetime NULL DEFAULT NULL COMMENT '离职时间',
  `graduate_school` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '毕业院校',
  `graduate_time` datetime NULL DEFAULT NULL COMMENT '毕业时间',
  `sort` int NOT NULL COMMENT '排序',
  `deleted` int NOT NULL DEFAULT 1 COMMENT '删除(0: 否; 1: 是)',
  `create_time` datetime NOT NULL,
  `creator` int NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `update_user` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_staff_company_id`(`company_id` ASC) USING BTREE,
  INDEX `fk_staff_dept_id`(`dept_id` ASC) USING BTREE,
  INDEX `fk_staff_stru_id`(`stru_id` ASC) USING BTREE,
  CONSTRAINT `fk_staff_company_id` FOREIGN KEY (`company_id`) REFERENCES `sys_company` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_staff_dept_id` FOREIGN KEY (`dept_id`) REFERENCES `sys_dept` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_staff_stru_id` FOREIGN KEY (`stru_id`) REFERENCES `sys_structure` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '人员' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_staff
-- ----------------------------

-- ----------------------------
-- Table structure for sys_staff_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_staff_post`;
CREATE TABLE `sys_staff_post`  (
  `staff_id` int NOT NULL COMMENT '人员主键',
  `post_id` int NOT NULL COMMENT '岗位主键',
  INDEX `fk_ssp_post_id`(`post_id` ASC) USING BTREE,
  INDEX `fk_ssp_staff_id`(`staff_id` ASC) USING BTREE,
  CONSTRAINT `fk_ssp_post_id` FOREIGN KEY (`post_id`) REFERENCES `sys_post` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_ssp_staff_id` FOREIGN KEY (`staff_id`) REFERENCES `sys_staff` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '人员岗位关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_staff_post
-- ----------------------------

-- ----------------------------
-- Table structure for sys_structure
-- ----------------------------
DROP TABLE IF EXISTS `sys_structure`;
CREATE TABLE `sys_structure`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `subject_id` int NOT NULL COMMENT '主体主键',
  `subject_type` int NOT NULL COMMENT '主体类型(0: 企业; 1:部门; 9: 人员)',
  `parent_id` int NULL DEFAULT 0 COMMENT '父级主键',
  `code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '编号',
  `parent_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '父级层级码',
  `level_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '层级码(父级和编号的拼接, 使用|做拼接符)',
  `deleted` int NOT NULL DEFAULT 0 COMMENT '删除(0: 否; 1: 是)',
  `create_time` datetime NULL DEFAULT NULL,
  `creator` int NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `update_user` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '结构表, 维护上下级关系' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_structure
-- ----------------------------
INSERT INTO `sys_structure` VALUES (1, -1, -1, -1, '', '', '', 0, '2023-05-10 16:38:51', 1, '2023-05-10 16:38:54', 1);

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户名',
  `account` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '账户',
  `password` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '密码',
  `dept_id` int NULL DEFAULT NULL COMMENT '部门主键',
  `stru_id` int NULL DEFAULT NULL COMMENT '结构主键',
  `staff_id` int NULL DEFAULT NULL COMMENT '人员主键',
  `status` int NOT NULL DEFAULT 1 COMMENT '账户状态(0: 正常; 1: 锁定; 2: 停用;)',
  `type` int NOT NULL DEFAULT 0 COMMENT '用户类型(0: 普通自注册用户; 1: 人员用户; 2: 系统管理用户)',
  `login_time` datetime NULL DEFAULT NULL COMMENT '上次登录时间',
  `expired_time` datetime NULL DEFAULT NULL COMMENT '账户过期时间',
  `locked_time` datetime NULL DEFAULT NULL COMMENT '锁定时间, 记录账户解锁时间',
  `failure_times` int NULL DEFAULT NULL COMMENT '失败次数,记录单次登录时的请求次数',
  `max_session` int NULL DEFAULT NULL COMMENT '最大会话数(<1为无限制)',
  `deleted` int NOT NULL DEFAULT 0 COMMENT '删除(0: 否; 1: 是)',
  `create_time` datetime NULL DEFAULT NULL,
  `creator` int NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `update_user` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户表(系统用户可直接创建; 普通用户需要先创建人员)' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, '小琳', 'xiao_lin', '$2a$10$7VvJRVcxXdFQpqQHT6MBzeS9Bvn/jygAof9rduhXp3rgS1/uqB.4e', NULL, NULL, NULL, 0, 2, NULL, NULL, NULL, NULL, NULL, 0, '2023-05-06 17:19:18', NULL, '2023-05-06 17:19:18', NULL);

SET FOREIGN_KEY_CHECKS = 1;
