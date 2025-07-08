/*
 Navicat Premium Dump SQL

 Source Server         : 192.168.5.117
 Source Server Type    : MySQL
 Source Server Version : 80042 (8.0.42)
 Source Host           : localhost:3306
 Source Schema         : gallerydb

 Target Server Type    : MySQL
 Target Server Version : 80042 (8.0.42)
 File Encoding         : 65001

 Date: 08/07/2025 07:24:46
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for alembic_version
-- ----------------------------
DROP TABLE IF EXISTS `alembic_version`;
CREATE TABLE `alembic_version`  (
  `version_num` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`version_num`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of alembic_version
-- ----------------------------
INSERT INTO `alembic_version` VALUES ('15332ef20667');

-- ----------------------------
-- Table structure for category
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `parent_id` int NULL DEFAULT NULL,
  `level` int NOT NULL,
  `sort_order` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ix_category_name`(`name` ASC) USING BTREE,
  INDEX `ix_category_id`(`id` ASC) USING BTREE,
  INDEX `ix_category_parent_id`(`parent_id` ASC) USING BTREE,
  CONSTRAINT `category_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `category` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 115 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of category
-- ----------------------------
INSERT INTO `category` VALUES (1, '办学方向与学校管理', '反映学校办学方向、党建、决策、制度及对外交流等方面的图片', NULL, 0, 0);
INSERT INTO `category` VALUES (2, '党建引领', '记录党组织活动、党员学习、党风廉政建设等相关图片', 1, 1, 0);
INSERT INTO `category` VALUES (3, '党员活动与学习', '记录党员组织生活、主题党日、学习交流等活动', 2, 2, 0);
INSERT INTO `category` VALUES (4, '党风廉政建设', '记录党风廉政教育、警示活动等相关图片', 2, 2, 1);
INSERT INTO `category` VALUES (5, '班子建设与决策', '记录领导班子会议、教职工代表大会等决策过程', 1, 1, 1);
INSERT INTO `category` VALUES (6, '领导班子会议', '记录校级行政会议、战略研讨会等', 5, 2, 0);
INSERT INTO `category` VALUES (7, '教职工代表大会', '记录教代会审议重要制度、选举等场景', 5, 2, 1);
INSERT INTO `category` VALUES (8, '制度与治理', '记录学校规章制度建设、安全管理与应急演练等', 1, 1, 2);
INSERT INTO `category` VALUES (9, '学校章程与制度宣传', '记录制度学习、宣传活动等图片', 8, 2, 0);
INSERT INTO `category` VALUES (10, '校务公开与民主监督', '记录校务公开栏、校长接待日等活动', 8, 2, 1);
INSERT INTO `category` VALUES (11, '安全管理与应急演练', '记录消防、防震、防疫等安全演练活动', 8, 2, 2);
INSERT INTO `category` VALUES (12, '对外交流与合作', '记录校际合作、社会共建、国际交流等活动', 1, 1, 3);
INSERT INTO `category` VALUES (13, '来访与出访', '记录国内外教育代表团来访或学校出访交流', 12, 2, 0);
INSERT INTO `category` VALUES (14, '校际合作 (含与曲阜师大合作)', '记录与兄弟院校及曲阜师范大学的合作项目', 12, 2, 1);
INSERT INTO `category` VALUES (15, '社会共建', '记录与企事业单位、社区的共建活动', 12, 2, 2);
INSERT INTO `category` VALUES (16, '招生与宣传', '记录招生宣传、校园开放日等相关活动', 1, 1, 4);
INSERT INTO `category` VALUES (17, '招生政策宣传', '记录招生简章、宣讲会等图片', 16, 2, 0);
INSERT INTO `category` VALUES (18, '校园开放日', '记录校园开放日活动，展示学校风貌', 16, 2, 1);
INSERT INTO `category` VALUES (19, '教师发展', '反映师德师风、专业成长、教研成果及荣誉表彰的图片', NULL, 0, 1);
INSERT INTO `category` VALUES (20, '师德师风建设', '记录师德教育、承诺宣誓、典型表彰等活动', 19, 1, 0);
INSERT INTO `category` VALUES (21, '师德教育与承诺', '记录师德规范学习、宣誓仪式等', 20, 2, 0);
INSERT INTO `category` VALUES (22, '师德典型与表彰', '记录师德标兵、模范教师的事迹与表彰', 20, 2, 1);
INSERT INTO `category` VALUES (23, '专业成长与培训', '记录教师参加的各类专业发展活动', 19, 1, 1);
INSERT INTO `category` VALUES (24, '新教师培训', '记录新教师入职培训、岗前培训等', 23, 2, 0);
INSERT INTO `category` VALUES (25, '校本研修与教研活动', '记录校内组织的教学工作坊、研讨会等', 23, 2, 1);
INSERT INTO `category` VALUES (26, '外出学习与专家讲座', '记录教师外出交流、参加专家讲座等', 23, 2, 2);
INSERT INTO `category` VALUES (27, '教学研究与成果', '记录教研组活动、课题研究、教学成果奖等', 19, 1, 2);
INSERT INTO `category` VALUES (28, '集体备课与听评课', '记录学科组集体备课、听课、评课活动', 27, 2, 0);
INSERT INTO `category` VALUES (29, '课题研究 (开题、中期、结题)', '记录各级课题研究过程中的重要节点', 27, 2, 1);
INSERT INTO `category` VALUES (30, '教学成果奖', '记录教师获得的各级教学成果奖项', 27, 2, 2);
INSERT INTO `category` VALUES (31, '荣誉与表彰', '记录教师获得的各级各类荣誉称号', 19, 1, 3);
INSERT INTO `category` VALUES (32, '各级教学能手/骨干教师', '记录省、市、校级教学能手、骨干教师风采', 31, 2, 0);
INSERT INTO `category` VALUES (33, '优秀教师/优秀班主任', '记录优秀教师、优秀班主任的表彰与事迹', 31, 2, 1);
INSERT INTO `category` VALUES (34, '课程与教学', '反映常规课堂、特色课程、实践活动及教学成果的图片', NULL, 0, 2);
INSERT INTO `category` VALUES (35, '常规课堂教学', '记录日常课堂教学活动，包括分科教学和选课走班', 34, 1, 0);
INSERT INTO `category` VALUES (36, '课堂风采 (分学科)', '记录不同学科的课堂教学精彩瞬间', 35, 2, 0);
INSERT INTO `category` VALUES (37, '选课走班', '记录高中选课走班的教学组织与实施', 35, 2, 1);
INSERT INTO `category` VALUES (38, '特色课程体系', '记录学校开设的各类特色校本课程', 34, 1, 1);
INSERT INTO `category` VALUES (39, '劳动教育', '记录校园保洁、手工制作、校外劳动等', 38, 2, 0);
INSERT INTO `category` VALUES (40, '传统文化教育 (含儒学)', '记录书法、国学、儒学经典诵读等活动', 38, 2, 1);
INSERT INTO `category` VALUES (41, '科创与信息技术教育', '记录编程、机器人、3D打印等科创活动', 38, 2, 2);
INSERT INTO `category` VALUES (42, '省级学科基地建设 (地理等)', '记录省级学科基地的建设过程与成果', 38, 2, 3);
INSERT INTO `category` VALUES (43, '实验与综合实践', '记录实验操作、研学旅行、社会考察等', 34, 1, 2);
INSERT INTO `category` VALUES (44, '理化生实验操作', '记录物理、化学、生物等学科的实验课', 43, 2, 0);
INSERT INTO `category` VALUES (45, '研学实践与社会考察', '记录学生走出校园进行的研学与社会考察', 43, 2, 1);
INSERT INTO `category` VALUES (46, '综合实践活动', '记录学校组织的各类综合性实践活动', 43, 2, 2);
INSERT INTO `category` VALUES (47, '教学资源与成果', '记录学生优秀作品及教师开发的教学资源', 34, 1, 3);
INSERT INTO `category` VALUES (48, '优秀作业/作品/实验报告', '展示学生优秀的作业、艺术作品、实验报告等', 47, 2, 0);
INSERT INTO `category` VALUES (49, '教学课件与资源', '存放教师制作的优秀课件及教学资源', 47, 2, 1);
INSERT INTO `category` VALUES (50, '学生成长', '反映学生思想道德、社团活动、身心健康及荣誉的图片', NULL, 0, 3);
INSERT INTO `category` VALUES (51, '思想道德教育', '记录学生思想品德教育的各类活动', 50, 1, 0);
INSERT INTO `category` VALUES (52, '主题班会与升旗仪式', '记录主题班会、升国旗仪式等德育活动', 51, 2, 0);
INSERT INTO `category` VALUES (53, '“扣好人生第一粒扣子”等主题活动', '记录“扣好人生第一粒扣子”等系列主题教育实践', 51, 2, 1);
INSERT INTO `category` VALUES (54, '志愿服务与社会实践', '记录学生参与的志愿服务和社会实践活动', 51, 2, 2);
INSERT INTO `category` VALUES (55, '学生组织与社团活动', '记录学生会、团委及各类学生社团的活动', 50, 1, 1);
INSERT INTO `category` VALUES (56, '学生会/团委/少先队', '记录学生干部组织、共青团、少先队的活动', 55, 2, 0);
INSERT INTO `category` VALUES (57, '各类学生社团', '记录科技、文体、艺术等学生社团的活动与成果', 55, 2, 1);
INSERT INTO `category` VALUES (58, '身心健康发展', '记录体育锻炼、心理健康教育等活动', 50, 1, 2);
INSERT INTO `category` VALUES (59, '体育锻炼与体质监测', '记录学生体育课、课外锻炼及体质测试', 58, 2, 0);
INSERT INTO `category` VALUES (60, '心理健康教育活动', '记录心理讲座、团体辅导、心理剧等', 58, 2, 1);
INSERT INTO `category` VALUES (61, '卫生与健康教育', '记录卫生习惯培养、健康知识讲座等', 58, 2, 2);
INSERT INTO `category` VALUES (62, '荣誉与风采', '记录学生获得的各级各类荣誉与奖项', 50, 1, 3);
INSERT INTO `category` VALUES (63, '各级三好学生/优秀干部', '记录三好学生、优秀学生干部的风采与表彰', 62, 2, 0);
INSERT INTO `category` VALUES (64, '“美德少年”等评选', '记录“美德少年”等德育评选活动', 62, 2, 1);
INSERT INTO `category` VALUES (65, '学科/文体/科技竞赛获奖', '记录学生在各类竞赛中获奖的瞬间', 62, 2, 2);
INSERT INTO `category` VALUES (66, '家校社协同育人', '记录家长会、教师家访等家校社合作活动', 50, 1, 4);
INSERT INTO `category` VALUES (67, '家长会与家长学校', '记录各年级家长会、家长学校讲座等', 66, 2, 0);
INSERT INTO `category` VALUES (68, '教师家访', '记录教师进行家访的活动图片', 66, 2, 1);
INSERT INTO `category` VALUES (69, '校园文化与环境', '反映校园节庆活动、风光设施、文化氛围及后勤保障的图片', NULL, 0, 4);
INSERT INTO `category` VALUES (70, '重大节庆活动', '记录学校举办的各类大型节庆活动', 69, 1, 0);
INSERT INTO `category` VALUES (71, '体育节/田径运动会', '记录校运会的开幕式、比赛、颁奖等', 70, 2, 0);
INSERT INTO `category` VALUES (72, '艺术节/文化节', '记录合唱、舞蹈、戏剧等文艺活动', 70, 2, 1);
INSERT INTO `category` VALUES (73, '科技节', '记录科技发明展览、科普讲座、模型比赛等', 70, 2, 2);
INSERT INTO `category` VALUES (74, '开学/毕业典礼', '记录开学典礼与毕业典礼的仪式', 70, 2, 3);
INSERT INTO `category` VALUES (75, '校园风光与设施', '记录校园的建筑、景观及各类硬件设施', 69, 1, 1);
INSERT INTO `category` VALUES (76, '校园建筑与四季风光', '记录不同季节的校园风光与标志性建筑', 75, 2, 0);
INSERT INTO `category` VALUES (77, '场馆设施 (图书馆、实验室、体育馆等)', '记录各类功能场馆的内部环境与设施', 75, 2, 1);
INSERT INTO `category` VALUES (78, '数字化校园建设', '记录智慧教室、在线平台等信息化建设成果', 75, 2, 2);
INSERT INTO `category` VALUES (79, '文化景观与氛围', '记录校园内的文化墙、宣传栏、校风校训等', 69, 1, 2);
INSERT INTO `category` VALUES (80, '宣传栏/文化墙/班级文化', '记录用于环境育人的各类文化景观', 79, 2, 0);
INSERT INTO `category` VALUES (81, '校风校训与校园标识', '记录校徽、校训、校歌等视觉识别元素', 79, 2, 1);
INSERT INTO `category` VALUES (82, '书香校园建设', '记录图书馆、读书节、阅读分享会等', 79, 2, 2);
INSERT INTO `category` VALUES (83, '后勤与安全保障', '记录食堂管理、校园安保、环境卫生等', 69, 1, 3);
INSERT INTO `category` VALUES (84, '食堂与住宿管理', '记录食堂备餐、宿舍环境等后勤服务', 83, 2, 0);
INSERT INTO `category` VALUES (85, '校园安保与环境卫生', '记录安保执勤、校园保洁等保障工作', 83, 2, 1);
INSERT INTO `category` VALUES (90, '摄影作品', '各类摄影作品展示', NULL, 0, 0);
INSERT INTO `category` VALUES (91, '设计作品', '平面设计和创意作品', NULL, 0, 0);
INSERT INTO `category` VALUES (92, '艺术创作', '绘画、雕塑等艺术作品', NULL, 0, 0);
INSERT INTO `category` VALUES (93, '数字媒体', '数字艺术和多媒体作品', NULL, 0, 0);
INSERT INTO `category` VALUES (94, '生活记录', '日常生活和旅行记录', NULL, 0, 0);
INSERT INTO `category` VALUES (95, '风光摄影', '自然风光和景观摄影', 90, 1, 0);
INSERT INTO `category` VALUES (96, '人像摄影', '人物肖像和写真摄影', 90, 1, 0);
INSERT INTO `category` VALUES (97, '街头摄影', '街头纪实和城市摄影', 90, 1, 0);
INSERT INTO `category` VALUES (98, '建筑摄影', '建筑和空间摄影', 90, 1, 0);
INSERT INTO `category` VALUES (99, '微距摄影', '微距和细节摄影', 90, 1, 0);
INSERT INTO `category` VALUES (100, '海报设计', '宣传海报和广告设计', 91, 1, 0);
INSERT INTO `category` VALUES (101, 'UI设计', '用户界面和交互设计', 91, 1, 0);
INSERT INTO `category` VALUES (102, '品牌设计', '品牌形象和标识设计', 91, 1, 0);
INSERT INTO `category` VALUES (103, '包装设计', '产品包装和展示设计', 91, 1, 0);
INSERT INTO `category` VALUES (104, '油画作品', '油画创作和展示', 92, 1, 0);
INSERT INTO `category` VALUES (105, '水彩画', '水彩画作品', 92, 1, 0);
INSERT INTO `category` VALUES (106, '素描作品', '素描和速写作品', 92, 1, 0);
INSERT INTO `category` VALUES (107, '数字绘画', '数字艺术创作', 92, 1, 0);
INSERT INTO `category` VALUES (108, '3D渲染', '三维建模和渲染作品', 93, 1, 0);
INSERT INTO `category` VALUES (109, '动画作品', '动画和动态图形', 93, 1, 0);
INSERT INTO `category` VALUES (110, '视频制作', '视频编辑和制作', 93, 1, 0);
INSERT INTO `category` VALUES (111, '旅行摄影', '旅行和探索记录', 94, 1, 0);
INSERT INTO `category` VALUES (112, '美食摄影', '美食和餐饮摄影', 94, 1, 0);
INSERT INTO `category` VALUES (113, '宠物摄影', '宠物和动物摄影', 94, 1, 0);
INSERT INTO `category` VALUES (114, '家庭摄影', '家庭和亲子摄影', 94, 1, 0);

-- ----------------------------
-- Table structure for comment
-- ----------------------------
DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `content` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `created_at` datetime NULL DEFAULT (now()),
  `content_id` int NOT NULL,
  `owner_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `content_id`(`content_id` ASC) USING BTREE,
  INDEX `owner_id`(`owner_id` ASC) USING BTREE,
  INDEX `ix_comment_id`(`id` ASC) USING BTREE,
  CONSTRAINT `comment_ibfk_1` FOREIGN KEY (`content_id`) REFERENCES `content` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `comment_ibfk_2` FOREIGN KEY (`owner_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 89 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of comment
-- ----------------------------
INSERT INTO `comment` VALUES (87, '好漂亮 ', '2025-06-27 00:36:37', 99, 1);

-- ----------------------------
-- Table structure for content
-- ----------------------------
DROP TABLE IF EXISTS `content`;
CREATE TABLE `content`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `content_type` enum('IMAGE','GALLERY') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `created_at` datetime NULL DEFAULT (now()),
  `updated_at` datetime NULL DEFAULT (now()),
  `owner_id` int NOT NULL,
  `category_id` int NULL DEFAULT NULL,
  `views_count` int NULL DEFAULT NULL,
  `likes_count` int NULL DEFAULT NULL,
  `bookmarks_count` int NULL DEFAULT NULL,
  `comments_count` int NULL DEFAULT NULL,
  `topic_id` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `category_id`(`category_id` ASC) USING BTREE,
  INDEX `owner_id`(`owner_id` ASC) USING BTREE,
  INDEX `ix_content_content_type`(`content_type` ASC) USING BTREE,
  INDEX `ix_content_id`(`id` ASC) USING BTREE,
  INDEX `ix_content_title`(`title` ASC) USING BTREE,
  INDEX `topic_id`(`topic_id` ASC) USING BTREE,
  CONSTRAINT `content_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `content_ibfk_2` FOREIGN KEY (`owner_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `content_ibfk_3` FOREIGN KEY (`topic_id`) REFERENCES `topic` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 230 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of content
-- ----------------------------
INSERT INTO `content` VALUES (56, 'GALLERY', '京剧行当卡通图', '京剧行当角度卡通图', '2025-06-24 03:22:21', '2025-07-07 15:56:40', 1, 2, 293, 1, 6, 0, 3);
INSERT INTO `content` VALUES (57, 'IMAGE', '京剧行当卡通图 - 01', '京剧行当角度卡通图', '2025-06-24 03:22:21', '2025-07-07 15:56:40', 1, 2, 294, 7, 3, 0, 3);
INSERT INTO `content` VALUES (58, 'IMAGE', '京剧行当卡通图 - 02', '京剧行当角度卡通图', '2025-06-24 03:22:21', '2025-07-07 15:56:40', 1, 2, 294, 10, 6, 0, 3);
INSERT INTO `content` VALUES (59, 'IMAGE', '京剧行当卡通图 - 03', '京剧行当角度卡通图', '2025-06-24 03:22:21', '2025-07-07 15:56:40', 1, 2, 293, 10, 4, 0, 3);
INSERT INTO `content` VALUES (60, 'IMAGE', '京剧行当卡通图 - 04', '京剧行当角度卡通图', '2025-06-24 03:22:21', '2025-07-07 15:56:40', 1, 2, 293, 12, 6, 0, 3);
INSERT INTO `content` VALUES (61, 'IMAGE', '京剧行当卡通图 - 05', '京剧行当角度卡通图', '2025-06-24 03:22:21', '2025-07-07 15:56:40', 1, 2, 293, 8, 4, 0, 3);
INSERT INTO `content` VALUES (62, 'IMAGE', '京剧行当卡通图 - 06', '京剧行当角度卡通图', '2025-06-24 03:22:21', '2025-07-07 15:56:40', 1, 2, 294, 18, 2, 0, 3);
INSERT INTO `content` VALUES (63, 'IMAGE', '京剧行当卡通图 - 07', '京剧行当角度卡通图', '2025-06-24 03:22:21', '2025-07-07 15:56:40', 1, 2, 298, 16, 4, 0, 3);
INSERT INTO `content` VALUES (64, 'GALLERY', '京剧卡通人物', '', '2025-06-24 03:37:27', '2025-07-07 15:56:40', 1, 2, 287, 0, 6, 0, 3);
INSERT INTO `content` VALUES (89, 'GALLERY', '测试上传图集', '', '2025-06-24 04:24:20', '2025-07-07 15:56:40', 1, 6, 272, 0, 7, 0, 1);
INSERT INTO `content` VALUES (93, 'IMAGE', '测试上传图集 - 04', NULL, '2025-06-24 04:24:20', '2025-07-07 15:56:40', 1, 6, 272, 10, 4, 0, 1);
INSERT INTO `content` VALUES (94, 'IMAGE', '测试上传图集 - 05', NULL, '2025-06-24 04:24:20', '2025-07-07 15:56:40', 1, 6, 272, 15, 4, 0, 1);
INSERT INTO `content` VALUES (98, 'IMAGE', 'Test Image 1', 'Testing instant upload 1', '2025-06-24 04:37:13', '2025-07-06 04:13:12', 1, NULL, 272, 0, 0, 0, NULL);
INSERT INTO `content` VALUES (99, 'IMAGE', 'Test Image 2', 'Testing instant upload 2', '2025-06-24 04:37:15', '2025-07-06 04:13:12', 1, NULL, 275, 0, 0, 0, NULL);
INSERT INTO `content` VALUES (100, 'GALLERY', '图集上传-1', '', '2025-06-24 04:39:59', '2025-07-07 15:56:40', 1, 1, 269, 2, 6, 0, 1);
INSERT INTO `content` VALUES (101, 'IMAGE', '图集上传-1 - 01', NULL, '2025-06-24 04:39:59', '2025-07-07 15:56:40', 1, 1, 272, 11, 5, 0, 1);
INSERT INTO `content` VALUES (102, 'IMAGE', '图集上传-1 - 02', NULL, '2025-06-24 04:39:59', '2025-07-07 15:56:40', 1, 1, 274, 17, 8, 0, 1);
INSERT INTO `content` VALUES (103, 'IMAGE', '图集上传-1 - 03', NULL, '2025-06-24 04:39:59', '2025-07-07 15:56:40', 1, 1, 280, 10, 1, 0, 1);
INSERT INTO `content` VALUES (109, 'GALLERY', '彩色羽毛', '', '2025-06-30 08:07:35', '2025-07-07 15:56:40', 16, 49, 196, 2, 4, 0, 5);
INSERT INTO `content` VALUES (110, 'IMAGE', '彩色羽毛 - 01', NULL, '2025-06-30 08:07:35', '2025-07-07 15:56:40', 16, 49, 260, 10, 3, 0, 5);
INSERT INTO `content` VALUES (111, 'IMAGE', '彩色羽毛 - 03', NULL, '2025-06-30 08:07:35', '2025-07-07 15:56:40', 16, 49, 206, 12, 10, 0, 5);
INSERT INTO `content` VALUES (136, 'GALLERY', '孔子像', '', '2025-06-30 16:22:17', '2025-07-07 15:56:40', 16, 40, 144, 2, 8, 0, 3);
INSERT INTO `content` VALUES (137, 'IMAGE', '孔子像 - 01', NULL, '2025-06-30 16:22:17', '2025-07-07 15:56:40', 16, NULL, 158, 16, 3, 0, NULL);
INSERT INTO `content` VALUES (145, 'IMAGE', '孔子像 - 1751427555459', NULL, '2025-07-02 03:39:15', '2025-07-07 15:56:40', 16, NULL, 129, 15, 7, 0, NULL);
INSERT INTO `content` VALUES (146, 'IMAGE', '孔子像 - 1751428312638', NULL, '2025-07-02 03:51:52', '2025-07-07 15:56:40', 16, 1, 124, 8, 9, 0, 3);
INSERT INTO `content` VALUES (147, 'IMAGE', '孔子像 - 1751428312764', NULL, '2025-07-02 03:51:52', '2025-07-07 15:56:40', 16, 1, 123, 10, 3, 0, 3);
INSERT INTO `content` VALUES (151, 'GALLERY', 'MSI壁纸123', '', '2025-07-05 11:14:32', '2025-07-07 15:56:40', 16, 80, 71, 1, 7, 0, 2);
INSERT INTO `content` VALUES (153, 'IMAGE', 'MSI壁纸 - 02', NULL, '2025-07-05 11:14:33', '2025-07-07 15:56:40', 16, 80, 76, 13, 7, 0, 2);
INSERT INTO `content` VALUES (154, 'IMAGE', 'MSI壁纸 - 01', NULL, '2025-07-05 11:14:33', '2025-07-07 15:56:40', 16, 80, 72, 11, 7, 0, 2);
INSERT INTO `content` VALUES (169, 'GALLERY', '手机测试', '', '2025-07-05 14:44:36', '2025-07-07 15:56:40', 26, 26, 23, 2, 6, 0, 4);
INSERT INTO `content` VALUES (170, 'IMAGE', '手机测试 - 01', NULL, '2025-07-05 14:44:36', '2025-07-07 15:56:40', 26, 26, 23, 8, 6, 0, 4);
INSERT INTO `content` VALUES (171, 'IMAGE', '手机测试 - 02', NULL, '2025-07-05 14:44:36', '2025-07-07 15:56:40', 26, 26, 23, 16, 7, 0, 4);
INSERT INTO `content` VALUES (175, 'IMAGE', '手机测试 - 1751726758339', NULL, '2025-07-05 14:45:57', '2025-07-07 15:56:40', 26, 26, 18, 8, 5, 0, 4);
INSERT INTO `content` VALUES (178, 'IMAGE', '手机测试 - 1751726759568', NULL, '2025-07-05 14:45:58', '2025-07-07 15:56:40', 26, 26, 18, 12, 7, 0, 4);
INSERT INTO `content` VALUES (179, 'GALLERY', '石榴花', '', '2025-07-05 14:59:08', '2025-07-07 15:56:40', 25, 79, 15, 1, 9, 0, 3);
INSERT INTO `content` VALUES (180, 'IMAGE', '石榴花 - 02', NULL, '2025-07-05 14:59:08', '2025-07-07 15:56:40', 25, 79, 17, 9, 5, 0, 3);
INSERT INTO `content` VALUES (181, 'IMAGE', '石榴花 - 01', NULL, '2025-07-05 14:59:08', '2025-07-07 15:56:40', 25, 79, 19, 11, 7, 0, 3);
INSERT INTO `content` VALUES (182, 'IMAGE', '师德师风建设系列 - 冬日', '通过巧妙的构图和光影运用，这幅师德师风建设作品呈现出令人印象深刻的视觉效果。', '2025-07-07 15:53:58', '2025-07-07 15:56:40', 45, 20, 130, 11, 4, 0, 9);
INSERT INTO `content` VALUES (183, 'IMAGE', '3D渲染摄影作品', '这是一幅精心创作的3D渲染作品，展现了独特的艺术魅力。', '2025-07-07 15:54:00', '2025-07-07 15:56:40', 45, 108, 264, 15, 2, 0, 9);
INSERT INTO `content` VALUES (184, 'IMAGE', '后勤与安全保障摄影作品', '捕捉到了后勤与安全保障的精髓，每一个细节都经过精心雕琢。', '2025-07-07 15:54:02', '2025-07-07 15:56:40', 45, 83, 481, 8, 15, 0, 9);
INSERT INTO `content` VALUES (185, 'IMAGE', '师德师风建设摄影作品', '这是一幅精心创作的师德师风建设作品，展现了独特的艺术魅力。', '2025-07-07 15:54:04', '2025-07-07 15:56:40', 45, 20, 380, 8, 9, 0, 9);
INSERT INTO `content` VALUES (186, 'IMAGE', '海报设计摄影作品', '捕捉到了海报设计的精髓，每一个细节都经过精心雕琢。', '2025-07-07 15:54:21', '2025-07-07 15:56:40', 45, 100, 277, 13, 2, 0, 9);
INSERT INTO `content` VALUES (187, 'IMAGE', '创意学生组织与社团活动', '捕捉到了学生组织与社团活动的精髓，每一个细节都经过精心雕琢。', '2025-07-07 15:54:23', '2025-07-07 15:56:40', 45, 55, 296, 6, 6, 0, 9);
INSERT INTO `content` VALUES (188, 'IMAGE', '精美的街头摄影作品', '这是一幅精心创作的街头摄影作品，展现了独特的艺术魅力。', '2025-07-07 15:54:24', '2025-07-07 15:56:40', 45, 97, 218, 20, 5, 0, 2);
INSERT INTO `content` VALUES (189, 'IMAGE', '精美的党建引领作品', '这幅作品展示了党建引领的独特美感和艺术价值。', '2025-07-07 15:54:27', '2025-07-07 15:56:40', 45, 2, 428, 17, 3, 0, 9);
INSERT INTO `content` VALUES (190, 'IMAGE', '创意建筑摄影', '这是一幅精心创作的建筑摄影作品，展现了独特的艺术魅力。', '2025-07-07 15:54:30', '2025-07-07 15:56:40', 46, 98, 284, 9, 7, 0, 2);
INSERT INTO `content` VALUES (191, 'IMAGE', '街头摄影系列 - 秋日', '捕捉到了街头摄影的精髓，每一个细节都经过精心雕琢。', '2025-07-07 15:54:31', '2025-07-07 15:56:40', 46, 97, 204, 9, 7, 0, 2);
INSERT INTO `content` VALUES (192, 'IMAGE', '建筑摄影摄影作品', '这幅作品展示了建筑摄影的独特美感和艺术价值。', '2025-07-07 15:54:34', '2025-07-07 15:56:40', 46, 98, 80, 11, 8, 0, 2);
INSERT INTO `content` VALUES (193, 'IMAGE', '创意校园风光与设施', '这幅作品展示了校园风光与设施的独特美感和艺术价值。', '2025-07-07 15:54:39', '2025-07-07 15:56:40', 46, 75, 416, 15, 3, 0, 9);
INSERT INTO `content` VALUES (194, 'IMAGE', '精美的街头摄影作品', '这是一幅精心创作的街头摄影作品，展现了独特的艺术魅力。', '2025-07-07 15:54:40', '2025-07-07 15:56:40', 46, 97, 60, 10, 4, 0, 2);
INSERT INTO `content` VALUES (195, 'IMAGE', '校园风光与设施摄影作品', '通过巧妙的构图和光影运用，这幅校园风光与设施作品呈现出令人印象深刻的视觉效果。', '2025-07-07 15:54:42', '2025-07-07 15:56:40', 46, 75, 263, 8, 5, 0, 9);
INSERT INTO `content` VALUES (196, 'IMAGE', '招生与宣传系列 - 冬日', '捕捉到了招生与宣传的精髓，每一个细节都经过精心雕琢。', '2025-07-07 15:54:44', '2025-07-07 15:56:40', 46, 16, 307, 12, 8, 0, 9);
INSERT INTO `content` VALUES (197, 'IMAGE', '创意水彩画', '这幅作品展示了水彩画的独特美感和艺术价值。', '2025-07-07 15:54:45', '2025-07-07 15:56:40', 46, 105, 334, 9, 3, 0, 9);
INSERT INTO `content` VALUES (198, 'IMAGE', '教学资源与成果系列 - 春日', '捕捉到了教学资源与成果的精髓，每一个细节都经过精心雕琢。', '2025-07-07 15:54:47', '2025-07-07 15:56:40', 47, 47, 42, 11, 2, 0, 9);
INSERT INTO `content` VALUES (199, 'IMAGE', '创意包装设计', '这幅作品展示了包装设计的独特美感和艺术价值。', '2025-07-07 15:54:50', '2025-07-07 15:56:40', 47, 103, 403, 13, 9, 0, 9);
INSERT INTO `content` VALUES (200, 'IMAGE', '动画作品系列 - 秋日', '捕捉到了动画作品的精髓，每一个细节都经过精心雕琢。', '2025-07-07 15:54:53', '2025-07-07 15:56:40', 47, 109, 464, 13, 6, 0, 9);
INSERT INTO `content` VALUES (201, 'IMAGE', '动画作品摄影作品', '捕捉到了动画作品的精髓，每一个细节都经过精心雕琢。', '2025-07-07 15:54:56', '2025-07-07 15:56:40', 47, 109, 475, 9, 2, 0, 9);
INSERT INTO `content` VALUES (202, 'IMAGE', '校园风光与设施系列 - 秋日', '捕捉到了校园风光与设施的精髓，每一个细节都经过精心雕琢。', '2025-07-07 15:54:58', '2025-07-07 15:56:40', 47, 75, 416, 16, 2, 0, 9);
INSERT INTO `content` VALUES (203, 'IMAGE', '对外交流与合作系列 - 春日', '捕捉到了对外交流与合作的精髓，每一个细节都经过精心雕琢。', '2025-07-07 15:55:00', '2025-07-07 15:56:40', 47, 12, 44, 13, 3, 0, 9);
INSERT INTO `content` VALUES (204, 'IMAGE', '创意常规课堂教学', '这是一幅精心创作的常规课堂教学作品，展现了独特的艺术魅力。', '2025-07-07 15:55:02', '2025-07-07 15:56:40', 47, 35, 24, 10, 4, 0, 9);
INSERT INTO `content` VALUES (205, 'IMAGE', '创意3D渲染', '这幅作品展示了3D渲染的独特美感和艺术价值。', '2025-07-07 15:55:04', '2025-07-07 15:56:40', 47, 108, 411, 14, 2, 0, 9);
INSERT INTO `content` VALUES (206, 'IMAGE', '家庭摄影系列 - 春日', '这幅作品展示了家庭摄影的独特美感和艺术价值。', '2025-07-07 15:55:06', '2025-07-07 15:56:40', 48, 114, 178, 16, 5, 0, 9);
INSERT INTO `content` VALUES (207, 'IMAGE', '招生与宣传摄影作品', '这幅作品展示了招生与宣传的独特美感和艺术价值。', '2025-07-07 15:55:08', '2025-07-07 15:56:40', 48, 16, 332, 10, 5, 0, 9);
INSERT INTO `content` VALUES (208, 'IMAGE', '包装设计系列 - 秋日', '捕捉到了包装设计的精髓，每一个细节都经过精心雕琢。', '2025-07-07 15:55:10', '2025-07-07 15:56:40', 48, 103, 437, 14, 4, 0, 9);
INSERT INTO `content` VALUES (209, 'IMAGE', '创意水彩画', '这幅作品展示了水彩画的独特美感和艺术价值。', '2025-07-07 15:55:11', '2025-07-07 15:56:40', 48, 105, 482, 7, 5, 0, 9);
INSERT INTO `content` VALUES (210, 'IMAGE', '建筑摄影系列 - 春日', '捕捉到了建筑摄影的精髓，每一个细节都经过精心雕琢。', '2025-07-07 15:55:14', '2025-07-07 15:56:40', 48, 98, 420, 13, 4, 0, 2);
INSERT INTO `content` VALUES (211, 'IMAGE', '文化景观与氛围系列 - 春日', '捕捉到了文化景观与氛围的精髓，每一个细节都经过精心雕琢。', '2025-07-07 15:55:18', '2025-07-07 15:56:40', 48, 79, 74, 12, 7, 0, 9);
INSERT INTO `content` VALUES (212, 'IMAGE', '精美的制度与治理作品', '这是一幅精心创作的制度与治理作品，展现了独特的艺术魅力。', '2025-07-07 15:55:20', '2025-07-07 15:56:40', 48, 8, 216, 11, 5, 0, 9);
INSERT INTO `content` VALUES (213, 'IMAGE', '精美的党建引领作品', '这幅作品展示了党建引领的独特美感和艺术价值。', '2025-07-07 15:55:22', '2025-07-07 15:56:40', 48, 2, 102, 17, 7, 0, 9);
INSERT INTO `content` VALUES (214, 'IMAGE', '精美的后勤与安全保障作品', '这是一幅精心创作的后勤与安全保障作品，展现了独特的艺术魅力。', '2025-07-07 15:55:24', '2025-07-07 15:56:40', 49, 83, 343, 15, 2, 0, 9);
INSERT INTO `content` VALUES (215, 'IMAGE', '校园风光与设施摄影作品', '这幅作品展示了校园风光与设施的独特美感和艺术价值。', '2025-07-07 15:55:25', '2025-07-07 15:56:40', 49, 75, 446, 13, 5, 0, 9);
INSERT INTO `content` VALUES (216, 'IMAGE', '创意荣誉与风采', '捕捉到了荣誉与风采的精髓，每一个细节都经过精心雕琢。', '2025-07-07 15:55:27', '2025-07-07 15:56:40', 49, 62, 328, 10, 9, 0, 9);
INSERT INTO `content` VALUES (217, 'IMAGE', '精美的学生组织与社团活动作品', '捕捉到了学生组织与社团活动的精髓，每一个细节都经过精心雕琢。', '2025-07-07 15:55:28', '2025-07-07 15:56:40', 49, 55, 140, 15, 3, 0, 9);
INSERT INTO `content` VALUES (218, 'IMAGE', '精美的水彩画作品', '捕捉到了水彩画的精髓，每一个细节都经过精心雕琢。', '2025-07-07 15:55:30', '2025-07-07 15:56:40', 49, 105, 454, 11, 4, 0, 9);
INSERT INTO `content` VALUES (219, 'IMAGE', '精美的宠物摄影作品', '这是一幅精心创作的宠物摄影作品，展现了独特的艺术魅力。', '2025-07-07 15:55:36', '2025-07-07 15:56:40', 49, 113, 292, 12, 8, 0, 9);
INSERT INTO `content` VALUES (220, 'IMAGE', '身心健康发展摄影作品', '这幅作品展示了身心健康发展的独特美感和艺术价值。', '2025-07-07 15:55:38', '2025-07-07 15:56:40', 49, 58, 282, 11, 4, 0, 9);
INSERT INTO `content` VALUES (221, 'GALLERY', 'photographer_zhang的摄影集', '这是photographer_zhang精心策划的作品集，收录了6张精选图片。', '2025-07-07 15:55:38', '2025-07-07 15:56:40', 45, 111, 166, 0, 6, 0, 7);
INSERT INTO `content` VALUES (222, 'GALLERY', '摄影实验作品', '这是designer_li精心策划的作品集，收录了4张精选图片。', '2025-07-07 15:55:38', '2025-07-07 15:56:40', 46, 16, 144, 0, 5, 0, 6);
INSERT INTO `content` VALUES (223, 'GALLERY', 'designer_li的摄影集', '这是designer_li精心策划的作品集，收录了4张精选图片。', '2025-07-07 15:55:39', '2025-07-07 15:56:40', 46, 83, 125, 0, 2, 0, 9);
INSERT INTO `content` VALUES (224, 'GALLERY', '精选作品集', '这是artist_wang精心策划的作品集，收录了5张精选图片。', '2025-07-07 15:55:39', '2025-07-07 15:56:40', 47, 55, 221, 0, 4, 0, 10);
INSERT INTO `content` VALUES (225, 'GALLERY', '个人摄影作品', '这是artist_wang精心策划的作品集，收录了3张精选图片。', '2025-07-07 15:55:39', '2025-07-07 15:56:40', 47, 23, 113, 0, 6, 0, 1);
INSERT INTO `content` VALUES (226, 'GALLERY', '创意作品集 - 春', '这是street_photographer精心策划的作品集，收录了4张精选图片。', '2025-07-07 15:55:39', '2025-07-07 15:56:40', 48, 99, 201, 0, 7, 0, 3);
INSERT INTO `content` VALUES (227, 'GALLERY', '艺术创作合集', '这是street_photographer精心策划的作品集，收录了3张精选图片。', '2025-07-07 15:55:39', '2025-07-07 15:56:40', 48, 96, 74, 0, 3, 0, 4);
INSERT INTO `content` VALUES (228, 'GALLERY', '个人摄影作品', '这是portrait_master精心策划的作品集，收录了3张精选图片。', '2025-07-07 15:55:39', '2025-07-07 15:56:40', 49, 20, 102, 0, 6, 0, 4);
INSERT INTO `content` VALUES (229, 'GALLERY', '精选作品集', '这是portrait_master精心策划的作品集，收录了3张精选图片。', '2025-07-07 15:56:17', '2025-07-07 15:56:40', 49, 66, 134, 0, 6, 0, 3);

-- ----------------------------
-- Table structure for content_bookmarks
-- ----------------------------
DROP TABLE IF EXISTS `content_bookmarks`;
CREATE TABLE `content_bookmarks`  (
  `user_id` int NOT NULL,
  `content_id` int NOT NULL,
  `created_at` datetime NULL DEFAULT (now()),
  PRIMARY KEY (`user_id`, `content_id`) USING BTREE,
  INDEX `content_id`(`content_id` ASC) USING BTREE,
  CONSTRAINT `content_bookmarks_ibfk_1` FOREIGN KEY (`content_id`) REFERENCES `content` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `content_bookmarks_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of content_bookmarks
-- ----------------------------
INSERT INTO `content_bookmarks` VALUES (1, 56, '2025-07-05 10:59:29');
INSERT INTO `content_bookmarks` VALUES (1, 63, '2025-06-30 16:42:28');
INSERT INTO `content_bookmarks` VALUES (1, 100, '2025-06-30 09:20:50');
INSERT INTO `content_bookmarks` VALUES (1, 101, '2025-06-26 10:50:22');
INSERT INTO `content_bookmarks` VALUES (1, 109, '2025-06-30 10:02:23');
INSERT INTO `content_bookmarks` VALUES (1, 110, '2025-06-30 12:24:17');
INSERT INTO `content_bookmarks` VALUES (1, 111, '2025-06-30 12:24:53');
INSERT INTO `content_bookmarks` VALUES (1, 136, '2025-07-05 12:26:30');
INSERT INTO `content_bookmarks` VALUES (1, 147, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (1, 151, '2025-07-05 12:26:16');
INSERT INTO `content_bookmarks` VALUES (1, 181, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (1, 182, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (1, 200, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (1, 212, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (1, 213, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (1, 215, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (1, 219, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (1, 229, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (2, 58, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (2, 59, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (2, 94, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (2, 111, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (2, 145, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (2, 154, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (2, 193, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (2, 204, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (2, 210, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (2, 217, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (2, 225, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (3, 58, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (3, 59, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (3, 169, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (3, 178, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (3, 179, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (3, 207, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (3, 211, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (3, 216, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (3, 222, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (3, 224, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (3, 225, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (4, 63, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (4, 179, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (4, 181, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (4, 206, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (4, 214, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (4, 226, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (5, 64, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (5, 180, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (5, 181, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (5, 188, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (5, 212, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (5, 214, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (6, 58, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (6, 59, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (6, 64, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (6, 94, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (6, 101, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (6, 146, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (6, 171, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (6, 180, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (6, 184, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (6, 190, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (6, 192, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (6, 199, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (6, 210, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (6, 213, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (6, 215, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (6, 226, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (7, 153, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (7, 169, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (7, 171, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (7, 183, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (7, 191, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (7, 213, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (7, 222, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (8, 56, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (8, 60, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (8, 175, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (8, 180, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (8, 184, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (8, 187, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (8, 190, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (8, 194, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (8, 201, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (8, 208, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (8, 225, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (8, 226, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (9, 171, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (9, 182, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (9, 210, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (9, 211, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (9, 215, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (10, 57, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (10, 60, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (10, 101, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (10, 111, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (10, 145, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (10, 170, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (10, 184, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (10, 185, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (10, 195, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (10, 196, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (10, 211, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (10, 216, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (10, 227, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (11, 62, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (11, 100, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (11, 146, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (11, 175, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (11, 181, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (11, 188, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (11, 189, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (11, 194, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (11, 207, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (11, 221, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (12, 60, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (12, 89, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (12, 136, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (12, 137, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (12, 184, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (12, 197, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (12, 208, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (12, 209, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (12, 215, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (13, 57, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (13, 111, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (13, 153, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (13, 170, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (13, 186, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (13, 228, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (14, 100, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (14, 101, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (14, 111, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (14, 137, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (14, 145, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (14, 146, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (14, 171, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (14, 178, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (14, 180, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (14, 184, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (14, 188, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (14, 202, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (14, 211, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (14, 215, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (14, 219, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (15, 58, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (15, 151, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (15, 179, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (15, 196, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (15, 207, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (15, 220, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (16, 94, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (16, 100, '2025-07-05 10:22:52');
INSERT INTO `content_bookmarks` VALUES (16, 101, '2025-06-30 07:16:11');
INSERT INTO `content_bookmarks` VALUES (16, 110, '2025-07-05 10:23:06');
INSERT INTO `content_bookmarks` VALUES (16, 111, '2025-06-30 16:16:37');
INSERT INTO `content_bookmarks` VALUES (16, 136, '2025-07-02 03:53:21');
INSERT INTO `content_bookmarks` VALUES (16, 137, '2025-06-30 16:28:37');
INSERT INTO `content_bookmarks` VALUES (16, 184, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (16, 185, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (16, 190, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (16, 219, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (17, 58, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (17, 100, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (17, 111, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (17, 147, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (17, 171, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (17, 192, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (17, 203, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (17, 216, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (17, 219, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (17, 221, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (17, 225, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (17, 226, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (17, 227, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (18, 102, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (18, 197, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (18, 206, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (18, 213, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (18, 216, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (18, 217, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (19, 151, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (19, 178, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (19, 181, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (19, 187, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (19, 191, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (19, 195, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (19, 202, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (19, 204, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (19, 206, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (19, 209, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (19, 216, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (19, 218, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (19, 224, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (19, 228, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (20, 61, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (20, 171, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (20, 178, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (20, 179, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (20, 185, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (20, 186, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (20, 196, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (20, 199, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (20, 200, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (21, 56, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (21, 102, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (21, 145, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (21, 153, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (21, 171, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (21, 178, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (21, 179, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (21, 196, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (21, 229, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (22, 89, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (22, 136, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (22, 185, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (22, 209, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (22, 221, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (23, 111, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (23, 147, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (23, 170, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (23, 184, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (23, 190, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (23, 196, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (23, 206, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (23, 218, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (24, 56, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (24, 64, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (24, 89, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (24, 93, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (24, 111, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (24, 136, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (24, 154, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (24, 191, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (24, 196, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (24, 228, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (24, 229, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (25, 59, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (25, 102, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (25, 146, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (25, 153, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (25, 169, '2025-07-05 15:08:11');
INSERT INTO `content_bookmarks` VALUES (25, 181, '2025-07-05 15:07:53');
INSERT INTO `content_bookmarks` VALUES (26, 64, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (26, 89, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (26, 169, '2025-07-05 14:44:46');
INSERT INTO `content_bookmarks` VALUES (26, 188, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (26, 191, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (26, 199, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (26, 216, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (26, 225, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (27, 64, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (27, 89, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (27, 136, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (27, 153, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (27, 154, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (27, 170, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (27, 184, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (27, 187, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (27, 192, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (27, 210, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (27, 211, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (27, 226, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (27, 228, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (28, 63, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (28, 102, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (28, 146, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (28, 179, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (28, 180, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (28, 192, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (28, 195, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (28, 199, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (28, 218, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (28, 221, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (28, 228, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (29, 58, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (29, 63, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (29, 109, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (29, 154, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (29, 207, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (29, 208, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (29, 222, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (30, 102, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (30, 198, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (30, 199, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (30, 200, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (30, 204, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (30, 213, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (30, 224, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (31, 60, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (31, 62, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (31, 93, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (31, 187, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (31, 191, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (31, 193, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (31, 198, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (31, 211, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (31, 216, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (31, 219, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (31, 220, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (32, 93, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (32, 100, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (32, 145, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (32, 181, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (32, 200, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (32, 204, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (32, 207, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (32, 212, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (32, 229, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (33, 61, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (33, 109, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (33, 145, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (33, 146, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (33, 153, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (33, 184, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (33, 192, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (33, 193, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (33, 195, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (33, 205, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (33, 216, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (33, 221, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (33, 222, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (33, 228, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (34, 136, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (34, 185, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (34, 219, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (35, 56, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (35, 60, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (35, 61, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (35, 93, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (35, 94, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (35, 151, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (35, 153, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (35, 184, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (35, 185, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (35, 187, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (35, 194, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (35, 203, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (35, 216, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (36, 102, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (36, 145, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (36, 169, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (36, 182, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (36, 184, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (36, 185, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (36, 190, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (36, 209, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (36, 213, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (36, 217, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (36, 219, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (37, 56, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (37, 102, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (37, 179, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (37, 190, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (37, 192, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (37, 196, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (37, 200, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (37, 219, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (37, 220, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (37, 225, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (38, 111, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (38, 146, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (38, 151, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (38, 178, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (38, 185, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (38, 192, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (38, 199, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (38, 209, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (38, 213, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (39, 175, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (39, 184, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (39, 192, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (39, 195, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (39, 220, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (39, 222, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (40, 136, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (40, 154, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (40, 184, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (40, 187, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (40, 191, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (40, 194, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (40, 199, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (40, 226, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (40, 229, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (44, 109, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (44, 182, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (44, 183, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (44, 211, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (44, 212, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (44, 223, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (44, 227, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (45, 60, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (45, 61, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (45, 64, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (45, 103, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (45, 151, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (45, 154, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (45, 170, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (45, 179, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (45, 199, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (45, 201, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (46, 102, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (46, 169, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (46, 226, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (46, 229, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (47, 57, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (47, 89, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (47, 151, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (47, 170, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (47, 175, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (47, 184, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (47, 185, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (47, 189, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (47, 190, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (47, 191, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (47, 196, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (47, 206, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (47, 208, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (47, 218, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (48, 146, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (48, 184, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (48, 189, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (48, 203, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (48, 205, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (48, 223, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (48, 224, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (49, 89, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (49, 110, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (49, 146, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (49, 154, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (49, 175, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (49, 178, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (49, 179, '2025-07-07 15:56:18');
INSERT INTO `content_bookmarks` VALUES (49, 188, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (49, 197, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (49, 199, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (49, 200, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (49, 212, '2025-07-07 15:56:40');
INSERT INTO `content_bookmarks` VALUES (49, 221, '2025-07-07 15:56:18');

-- ----------------------------
-- Table structure for content_likes
-- ----------------------------
DROP TABLE IF EXISTS `content_likes`;
CREATE TABLE `content_likes`  (
  `user_id` int NOT NULL,
  `content_id` int NOT NULL,
  `created_at` datetime NULL DEFAULT (now()),
  PRIMARY KEY (`user_id`, `content_id`) USING BTREE,
  INDEX `content_id`(`content_id` ASC) USING BTREE,
  CONSTRAINT `content_likes_ibfk_1` FOREIGN KEY (`content_id`) REFERENCES `content` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `content_likes_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of content_likes
-- ----------------------------
INSERT INTO `content_likes` VALUES (1, 56, '2025-07-05 10:59:28');
INSERT INTO `content_likes` VALUES (1, 63, '2025-06-30 16:42:28');
INSERT INTO `content_likes` VALUES (1, 100, '2025-06-30 09:20:49');
INSERT INTO `content_likes` VALUES (1, 101, '2025-06-26 10:50:21');
INSERT INTO `content_likes` VALUES (1, 102, '2025-06-30 16:41:11');
INSERT INTO `content_likes` VALUES (1, 109, '2025-06-30 10:02:23');
INSERT INTO `content_likes` VALUES (1, 110, '2025-06-30 12:24:19');
INSERT INTO `content_likes` VALUES (1, 111, '2025-06-30 12:24:54');
INSERT INTO `content_likes` VALUES (1, 136, '2025-07-05 12:26:27');
INSERT INTO `content_likes` VALUES (1, 151, '2025-07-05 12:26:15');
INSERT INTO `content_likes` VALUES (1, 153, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (1, 171, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (1, 178, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (1, 180, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (1, 182, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (1, 184, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (1, 185, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (1, 188, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (1, 189, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (1, 191, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (1, 192, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (1, 195, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (1, 196, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (1, 200, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (1, 202, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (1, 205, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (1, 209, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (1, 211, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (1, 215, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (1, 216, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (1, 220, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (2, 57, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (2, 60, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (2, 61, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (2, 62, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (2, 63, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (2, 94, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (2, 154, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (2, 189, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (2, 191, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (2, 192, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (2, 194, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (2, 199, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (2, 201, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (2, 203, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (2, 204, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (2, 206, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (2, 212, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (2, 213, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (2, 215, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (2, 217, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (3, 58, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (3, 60, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (3, 63, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (3, 102, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (3, 110, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (3, 111, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (3, 137, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (3, 145, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (3, 147, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (3, 153, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (3, 171, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (3, 178, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (3, 182, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (3, 183, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (3, 196, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (3, 198, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (3, 205, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (3, 206, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (3, 210, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (3, 211, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (3, 217, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (4, 62, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (4, 110, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (4, 145, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (4, 188, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (4, 196, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (4, 205, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (4, 208, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (4, 211, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (4, 213, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (4, 214, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (4, 215, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (5, 57, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (5, 93, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (5, 94, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (5, 102, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (5, 111, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (5, 145, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (5, 153, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (5, 171, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (5, 175, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (5, 192, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (5, 193, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (5, 195, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (5, 199, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (5, 205, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (5, 211, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (5, 212, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (5, 213, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (6, 62, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (6, 94, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (6, 146, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (6, 180, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (6, 181, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (6, 190, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (6, 200, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (6, 202, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (6, 203, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (6, 205, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (6, 211, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (6, 220, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (7, 60, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (7, 62, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (7, 93, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (7, 110, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (7, 145, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (7, 146, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (7, 147, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (7, 154, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (7, 181, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (7, 184, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (7, 186, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (7, 188, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (7, 189, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (7, 192, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (7, 195, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (7, 196, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (7, 198, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (7, 200, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (7, 201, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (7, 202, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (7, 212, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (7, 213, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (7, 217, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (8, 63, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (8, 93, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (8, 94, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (8, 102, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (8, 137, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (8, 145, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (8, 181, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (8, 182, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (8, 186, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (8, 187, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (8, 191, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (8, 193, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (8, 194, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (8, 198, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (8, 199, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (8, 201, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (8, 202, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (8, 203, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (8, 204, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (8, 207, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (8, 208, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (8, 210, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (8, 211, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (8, 212, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (8, 214, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (8, 220, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (9, 60, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (9, 62, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (9, 94, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (9, 137, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (9, 145, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (9, 178, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (9, 180, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (9, 183, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (9, 184, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (9, 185, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (9, 187, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (9, 190, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (9, 191, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (9, 193, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (9, 198, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (9, 199, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (9, 202, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (9, 203, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (9, 220, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (10, 57, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (10, 59, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (10, 62, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (10, 111, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (10, 153, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (10, 154, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (10, 170, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (10, 175, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (10, 182, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (10, 188, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (10, 189, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (10, 190, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (10, 193, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (10, 197, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (10, 206, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (10, 210, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (10, 214, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (11, 59, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (11, 62, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (11, 63, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (11, 93, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (11, 137, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (11, 145, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (11, 154, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (11, 183, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (11, 185, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (11, 186, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (11, 188, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (11, 213, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (11, 215, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (11, 217, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (12, 58, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (12, 137, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (12, 146, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (12, 175, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (12, 189, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (12, 193, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (12, 196, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (12, 201, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (12, 210, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (12, 212, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (12, 218, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (12, 220, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (13, 58, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (13, 63, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (13, 153, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (13, 183, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (13, 189, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (13, 191, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (13, 194, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (13, 210, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (13, 217, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (14, 58, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (14, 61, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (14, 110, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (14, 147, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (14, 171, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (14, 182, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (14, 188, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (14, 192, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (14, 196, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (14, 197, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (14, 200, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (14, 203, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (14, 206, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (14, 209, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (14, 210, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (14, 216, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (14, 217, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (14, 218, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (14, 219, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (15, 59, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (15, 61, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (15, 62, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (15, 94, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (15, 102, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (15, 145, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (15, 146, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (15, 153, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (15, 185, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (15, 188, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (15, 193, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (15, 200, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (15, 208, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (15, 212, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (15, 213, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (15, 214, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (15, 220, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (16, 100, '2025-07-05 10:22:52');
INSERT INTO `content_likes` VALUES (16, 101, '2025-06-30 07:16:10');
INSERT INTO `content_likes` VALUES (16, 102, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (16, 109, '2025-06-30 16:32:43');
INSERT INTO `content_likes` VALUES (16, 110, '2025-07-05 10:23:07');
INSERT INTO `content_likes` VALUES (16, 111, '2025-06-30 16:16:38');
INSERT INTO `content_likes` VALUES (16, 136, '2025-07-02 03:53:20');
INSERT INTO `content_likes` VALUES (16, 137, '2025-06-30 16:28:36');
INSERT INTO `content_likes` VALUES (16, 171, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (16, 178, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (16, 183, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (16, 195, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (16, 196, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (16, 198, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (16, 200, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (16, 203, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (16, 204, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (16, 207, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (16, 215, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (16, 219, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (17, 58, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (17, 94, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (17, 110, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (17, 137, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (17, 171, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (17, 180, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (17, 188, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (17, 192, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (17, 203, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (17, 213, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (17, 214, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (17, 219, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (17, 220, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (18, 103, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (18, 171, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (18, 175, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (18, 178, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (18, 188, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (18, 189, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (18, 200, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (18, 205, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (18, 206, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (18, 212, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (19, 60, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (19, 102, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (19, 103, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (19, 111, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (19, 137, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (19, 171, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (19, 178, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (19, 183, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (19, 188, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (19, 191, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (19, 200, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (19, 203, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (19, 204, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (19, 206, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (19, 207, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (19, 208, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (19, 214, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (19, 217, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (20, 57, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (20, 58, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (20, 62, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (20, 94, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (20, 101, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (20, 145, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (20, 183, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (20, 184, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (20, 192, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (20, 193, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (20, 201, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (20, 202, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (20, 204, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (20, 212, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (20, 216, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (20, 218, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (21, 59, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (21, 61, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (21, 63, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (21, 145, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (21, 170, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (21, 178, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (21, 180, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (21, 181, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (21, 183, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (21, 186, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (21, 188, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (21, 204, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (21, 205, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (21, 206, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (21, 207, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (21, 209, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (21, 213, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (21, 215, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (21, 219, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (22, 103, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (22, 145, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (22, 186, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (22, 189, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (22, 190, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (22, 191, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (22, 197, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (22, 198, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (22, 199, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (22, 201, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (22, 205, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (22, 206, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (22, 208, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (22, 214, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (22, 216, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (22, 218, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (23, 58, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (23, 101, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (23, 102, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (23, 137, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (23, 153, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (23, 154, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (23, 175, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (23, 178, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (23, 188, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (23, 189, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (23, 192, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (23, 196, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (23, 204, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (23, 205, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (23, 207, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (23, 208, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (23, 212, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (23, 215, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (24, 58, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (24, 60, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (24, 101, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (24, 102, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (24, 111, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (24, 146, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (24, 180, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (24, 182, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (24, 183, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (24, 186, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (24, 187, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (24, 188, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (24, 192, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (24, 194, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (24, 195, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (24, 196, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (24, 199, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (24, 200, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (24, 214, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (24, 215, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (24, 217, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (24, 219, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (25, 62, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (25, 63, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (25, 101, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (25, 103, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (25, 111, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (25, 146, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (25, 169, '2025-07-05 15:08:10');
INSERT INTO `content_likes` VALUES (25, 170, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (25, 171, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (25, 179, '2025-07-05 15:23:30');
INSERT INTO `content_likes` VALUES (25, 181, '2025-07-05 15:07:56');
INSERT INTO `content_likes` VALUES (25, 182, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (25, 183, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (25, 192, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (25, 193, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (25, 194, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (25, 206, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (25, 207, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (25, 208, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (25, 210, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (25, 211, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (25, 213, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (25, 215, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (25, 217, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (26, 94, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (26, 101, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (26, 137, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (26, 169, '2025-07-05 14:44:45');
INSERT INTO `content_likes` VALUES (26, 181, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (26, 193, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (26, 204, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (26, 206, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (26, 209, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (26, 212, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (26, 213, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (26, 217, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (27, 60, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (27, 62, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (27, 93, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (27, 94, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (27, 111, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (27, 145, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (27, 153, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (27, 154, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (27, 171, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (27, 175, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (27, 182, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (27, 188, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (27, 190, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (27, 193, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (27, 194, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (27, 199, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (27, 201, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (27, 202, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (27, 210, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (27, 215, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (27, 216, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (27, 217, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (27, 220, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (28, 102, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (28, 154, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (28, 182, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (28, 186, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (28, 188, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (28, 199, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (28, 204, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (28, 208, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (28, 214, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (28, 216, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (28, 219, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (29, 57, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (29, 94, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (29, 103, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (29, 147, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (29, 153, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (29, 170, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (29, 171, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (29, 184, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (29, 186, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (29, 188, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (29, 190, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (29, 192, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (29, 197, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (29, 204, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (29, 205, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (29, 206, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (29, 214, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (29, 217, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (29, 219, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (29, 220, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (30, 60, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (30, 63, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (30, 94, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (30, 147, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (30, 180, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (30, 184, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (30, 188, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (30, 190, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (30, 193, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (30, 195, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (30, 196, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (30, 200, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (30, 201, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (30, 202, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (30, 203, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (30, 206, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (30, 208, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (30, 211, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (30, 213, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (30, 214, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (30, 218, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (31, 59, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (31, 93, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (31, 111, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (31, 153, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (31, 178, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (31, 184, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (31, 186, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (31, 191, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (31, 196, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (31, 202, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (31, 203, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (31, 217, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (31, 218, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (31, 219, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (32, 102, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (32, 103, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (32, 110, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (32, 147, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (32, 154, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (32, 175, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (32, 181, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (32, 189, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (32, 193, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (32, 194, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (32, 197, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (32, 198, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (32, 202, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (32, 205, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (32, 210, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (32, 218, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (33, 58, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (33, 61, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (33, 93, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (33, 101, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (33, 103, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (33, 111, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (33, 137, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (33, 154, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (33, 180, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (33, 183, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (33, 189, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (33, 193, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (33, 196, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (33, 197, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (33, 199, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (33, 206, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (33, 215, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (33, 216, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (34, 101, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (34, 110, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (34, 145, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (34, 147, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (34, 170, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (34, 171, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (34, 178, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (34, 183, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (34, 185, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (34, 187, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (34, 198, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (34, 199, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (34, 201, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (34, 202, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (34, 203, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (34, 210, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (34, 216, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (34, 218, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (34, 219, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (35, 59, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (35, 60, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (35, 61, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (35, 62, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (35, 93, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (35, 102, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (35, 137, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (35, 147, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (35, 170, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (35, 186, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (35, 193, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (35, 202, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (35, 205, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (35, 206, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (35, 208, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (35, 213, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (35, 219, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (36, 60, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (36, 61, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (36, 103, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (36, 178, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (36, 185, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (36, 189, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (36, 195, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (36, 198, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (36, 199, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (36, 207, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (37, 62, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (37, 63, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (37, 181, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (37, 187, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (37, 188, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (37, 209, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (37, 213, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (37, 214, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (37, 215, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (38, 59, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (38, 63, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (38, 145, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (38, 146, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (38, 153, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (38, 182, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (38, 197, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (38, 198, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (38, 213, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (38, 216, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (38, 219, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (39, 57, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (39, 63, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (39, 103, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (39, 183, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (39, 190, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (39, 207, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (40, 62, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (40, 101, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (40, 137, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (40, 154, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (40, 180, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (40, 181, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (40, 186, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (40, 187, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (40, 189, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (40, 194, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (40, 202, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (40, 203, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (40, 206, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (40, 207, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (40, 210, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (40, 211, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (40, 214, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (40, 219, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (40, 220, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (44, 59, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (44, 62, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (44, 102, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (44, 153, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (44, 154, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (44, 170, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (44, 182, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (44, 185, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (44, 186, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (44, 188, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (44, 190, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (44, 191, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (44, 193, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (44, 194, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (44, 198, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (44, 199, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (44, 200, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (44, 205, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (44, 208, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (44, 209, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (44, 210, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (44, 211, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (44, 213, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (44, 215, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (44, 216, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (45, 57, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (45, 59, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (45, 61, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (45, 63, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (45, 102, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (45, 171, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (45, 199, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (45, 200, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (45, 202, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (45, 203, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (45, 208, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (45, 210, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (45, 211, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (45, 213, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (45, 214, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (46, 62, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (46, 94, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (46, 102, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (46, 147, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (46, 153, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (46, 171, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (46, 175, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (46, 178, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (46, 181, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (46, 183, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (46, 188, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (46, 189, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (46, 202, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (46, 208, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (46, 211, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (46, 217, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (46, 218, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (47, 58, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (47, 60, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (47, 63, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (47, 93, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (47, 102, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (47, 137, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (47, 170, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (47, 189, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (47, 195, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (47, 197, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (47, 208, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (47, 218, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (48, 62, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (48, 63, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (48, 93, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (48, 94, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (48, 101, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (48, 110, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (48, 111, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (48, 137, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (48, 147, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (48, 171, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (48, 183, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (48, 184, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (48, 186, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (48, 189, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (48, 194, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (48, 214, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (48, 217, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (48, 218, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (48, 220, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (49, 59, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (49, 60, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (49, 62, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (49, 63, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (49, 94, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (49, 102, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (49, 103, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (49, 137, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (49, 145, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (49, 146, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (49, 171, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (49, 181, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (49, 185, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (49, 189, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (49, 197, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (49, 200, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (49, 202, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (49, 205, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (49, 206, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (49, 207, '2025-07-07 15:56:18');
INSERT INTO `content_likes` VALUES (49, 209, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (49, 212, '2025-07-07 15:56:40');
INSERT INTO `content_likes` VALUES (49, 213, '2025-07-07 15:56:40');

-- ----------------------------
-- Table structure for content_tags
-- ----------------------------
DROP TABLE IF EXISTS `content_tags`;
CREATE TABLE `content_tags`  (
  `content_id` int NOT NULL,
  `tag_id` int NOT NULL,
  `created_at` datetime NULL DEFAULT (now()),
  PRIMARY KEY (`content_id`, `tag_id`) USING BTREE,
  INDEX `tag_id`(`tag_id` ASC) USING BTREE,
  CONSTRAINT `content_tags_ibfk_1` FOREIGN KEY (`content_id`) REFERENCES `content` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `content_tags_ibfk_2` FOREIGN KEY (`tag_id`) REFERENCES `tag` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of content_tags
-- ----------------------------
INSERT INTO `content_tags` VALUES (111, 49, '2025-06-30 08:07:42');
INSERT INTO `content_tags` VALUES (111, 50, '2025-06-30 08:07:42');
INSERT INTO `content_tags` VALUES (111, 51, '2025-06-30 08:07:42');
INSERT INTO `content_tags` VALUES (111, 52, '2025-06-30 08:07:42');
INSERT INTO `content_tags` VALUES (111, 53, '2025-06-30 08:07:42');
INSERT INTO `content_tags` VALUES (111, 54, '2025-06-30 08:07:42');
INSERT INTO `content_tags` VALUES (136, 102, '2025-07-02 03:51:52');
INSERT INTO `content_tags` VALUES (137, 67, '2025-06-30 16:22:24');
INSERT INTO `content_tags` VALUES (137, 84, '2025-06-30 16:22:24');
INSERT INTO `content_tags` VALUES (137, 89, '2025-06-30 16:22:24');
INSERT INTO `content_tags` VALUES (137, 99, '2025-06-30 16:22:24');
INSERT INTO `content_tags` VALUES (137, 100, '2025-06-30 16:22:24');
INSERT INTO `content_tags` VALUES (137, 101, '2025-06-30 16:22:24');
INSERT INTO `content_tags` VALUES (146, 102, '2025-07-02 03:51:52');
INSERT INTO `content_tags` VALUES (147, 102, '2025-07-02 03:51:52');
INSERT INTO `content_tags` VALUES (182, 122, '2025-07-07 15:53:58');
INSERT INTO `content_tags` VALUES (182, 142, '2025-07-07 15:53:58');
INSERT INTO `content_tags` VALUES (183, 122, '2025-07-07 15:54:00');
INSERT INTO `content_tags` VALUES (183, 142, '2025-07-07 15:54:00');
INSERT INTO `content_tags` VALUES (184, 122, '2025-07-07 15:54:02');
INSERT INTO `content_tags` VALUES (184, 142, '2025-07-07 15:54:02');
INSERT INTO `content_tags` VALUES (185, 122, '2025-07-07 15:54:04');
INSERT INTO `content_tags` VALUES (185, 142, '2025-07-07 15:54:04');
INSERT INTO `content_tags` VALUES (186, 122, '2025-07-07 15:54:21');
INSERT INTO `content_tags` VALUES (186, 142, '2025-07-07 15:54:21');
INSERT INTO `content_tags` VALUES (187, 122, '2025-07-07 15:54:23');
INSERT INTO `content_tags` VALUES (187, 142, '2025-07-07 15:54:23');
INSERT INTO `content_tags` VALUES (188, 143, '2025-07-07 15:54:24');
INSERT INTO `content_tags` VALUES (188, 144, '2025-07-07 15:54:24');
INSERT INTO `content_tags` VALUES (189, 122, '2025-07-07 15:54:27');
INSERT INTO `content_tags` VALUES (189, 142, '2025-07-07 15:54:27');
INSERT INTO `content_tags` VALUES (190, 116, '2025-07-07 15:54:30');
INSERT INTO `content_tags` VALUES (190, 117, '2025-07-07 15:54:30');
INSERT INTO `content_tags` VALUES (190, 145, '2025-07-07 15:54:30');
INSERT INTO `content_tags` VALUES (191, 110, '2025-07-07 15:54:31');
INSERT INTO `content_tags` VALUES (191, 116, '2025-07-07 15:54:31');
INSERT INTO `content_tags` VALUES (191, 143, '2025-07-07 15:54:31');
INSERT INTO `content_tags` VALUES (191, 144, '2025-07-07 15:54:31');
INSERT INTO `content_tags` VALUES (192, 110, '2025-07-07 15:54:34');
INSERT INTO `content_tags` VALUES (192, 117, '2025-07-07 15:54:34');
INSERT INTO `content_tags` VALUES (193, 122, '2025-07-07 15:54:39');
INSERT INTO `content_tags` VALUES (193, 142, '2025-07-07 15:54:39');
INSERT INTO `content_tags` VALUES (194, 110, '2025-07-07 15:54:40');
INSERT INTO `content_tags` VALUES (194, 116, '2025-07-07 15:54:40');
INSERT INTO `content_tags` VALUES (195, 122, '2025-07-07 15:54:42');
INSERT INTO `content_tags` VALUES (195, 142, '2025-07-07 15:54:42');
INSERT INTO `content_tags` VALUES (196, 122, '2025-07-07 15:54:44');
INSERT INTO `content_tags` VALUES (196, 142, '2025-07-07 15:54:44');
INSERT INTO `content_tags` VALUES (197, 122, '2025-07-07 15:54:45');
INSERT INTO `content_tags` VALUES (197, 142, '2025-07-07 15:54:45');
INSERT INTO `content_tags` VALUES (198, 122, '2025-07-07 15:54:47');
INSERT INTO `content_tags` VALUES (198, 142, '2025-07-07 15:54:47');
INSERT INTO `content_tags` VALUES (199, 122, '2025-07-07 15:54:50');
INSERT INTO `content_tags` VALUES (199, 142, '2025-07-07 15:54:50');
INSERT INTO `content_tags` VALUES (200, 122, '2025-07-07 15:54:53');
INSERT INTO `content_tags` VALUES (200, 142, '2025-07-07 15:54:53');
INSERT INTO `content_tags` VALUES (201, 122, '2025-07-07 15:54:56');
INSERT INTO `content_tags` VALUES (201, 142, '2025-07-07 15:54:56');
INSERT INTO `content_tags` VALUES (202, 122, '2025-07-07 15:54:58');
INSERT INTO `content_tags` VALUES (202, 142, '2025-07-07 15:54:58');
INSERT INTO `content_tags` VALUES (203, 122, '2025-07-07 15:55:00');
INSERT INTO `content_tags` VALUES (203, 142, '2025-07-07 15:55:00');
INSERT INTO `content_tags` VALUES (204, 122, '2025-07-07 15:55:02');
INSERT INTO `content_tags` VALUES (204, 142, '2025-07-07 15:55:02');
INSERT INTO `content_tags` VALUES (205, 122, '2025-07-07 15:55:04');
INSERT INTO `content_tags` VALUES (205, 142, '2025-07-07 15:55:04');
INSERT INTO `content_tags` VALUES (206, 122, '2025-07-07 15:55:06');
INSERT INTO `content_tags` VALUES (206, 142, '2025-07-07 15:55:06');
INSERT INTO `content_tags` VALUES (207, 122, '2025-07-07 15:55:08');
INSERT INTO `content_tags` VALUES (207, 142, '2025-07-07 15:55:08');
INSERT INTO `content_tags` VALUES (208, 122, '2025-07-07 15:55:10');
INSERT INTO `content_tags` VALUES (208, 142, '2025-07-07 15:55:10');
INSERT INTO `content_tags` VALUES (209, 122, '2025-07-07 15:55:11');
INSERT INTO `content_tags` VALUES (209, 142, '2025-07-07 15:55:11');
INSERT INTO `content_tags` VALUES (210, 110, '2025-07-07 15:55:14');
INSERT INTO `content_tags` VALUES (210, 117, '2025-07-07 15:55:14');
INSERT INTO `content_tags` VALUES (211, 122, '2025-07-07 15:55:18');
INSERT INTO `content_tags` VALUES (211, 142, '2025-07-07 15:55:18');
INSERT INTO `content_tags` VALUES (212, 122, '2025-07-07 15:55:20');
INSERT INTO `content_tags` VALUES (212, 142, '2025-07-07 15:55:20');
INSERT INTO `content_tags` VALUES (213, 122, '2025-07-07 15:55:22');
INSERT INTO `content_tags` VALUES (213, 142, '2025-07-07 15:55:22');
INSERT INTO `content_tags` VALUES (214, 122, '2025-07-07 15:55:24');
INSERT INTO `content_tags` VALUES (214, 142, '2025-07-07 15:55:24');
INSERT INTO `content_tags` VALUES (215, 122, '2025-07-07 15:55:25');
INSERT INTO `content_tags` VALUES (215, 142, '2025-07-07 15:55:25');
INSERT INTO `content_tags` VALUES (216, 122, '2025-07-07 15:55:27');
INSERT INTO `content_tags` VALUES (216, 142, '2025-07-07 15:55:27');
INSERT INTO `content_tags` VALUES (217, 122, '2025-07-07 15:55:28');
INSERT INTO `content_tags` VALUES (217, 142, '2025-07-07 15:55:28');
INSERT INTO `content_tags` VALUES (218, 122, '2025-07-07 15:55:30');
INSERT INTO `content_tags` VALUES (218, 142, '2025-07-07 15:55:30');
INSERT INTO `content_tags` VALUES (219, 122, '2025-07-07 15:55:36');
INSERT INTO `content_tags` VALUES (219, 142, '2025-07-07 15:55:36');
INSERT INTO `content_tags` VALUES (220, 122, '2025-07-07 15:55:38');
INSERT INTO `content_tags` VALUES (220, 142, '2025-07-07 15:55:38');

-- ----------------------------
-- Table structure for department
-- ----------------------------
DROP TABLE IF EXISTS `department`;
CREATE TABLE `department`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ix_department_name`(`name` ASC) USING BTREE,
  INDEX `ix_department_id`(`id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 27 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of department
-- ----------------------------
INSERT INTO `department` VALUES (1, '党政办公室', '党政办公室');
INSERT INTO `department` VALUES (2, '教务处', '教育教学管理');
INSERT INTO `department` VALUES (3, '学生工作处', '学生及班主任工作');
INSERT INTO `department` VALUES (4, '后勤管理处', '后勤基础设施保障与服务');
INSERT INTO `department` VALUES (5, '电教中心', '电教及信息化设备保障与服务');
INSERT INTO `department` VALUES (6, '综合管理办公室', '综合与安全管理');
INSERT INTO `department` VALUES (7, '小学级部', '小学年级管理');
INSERT INTO `department` VALUES (8, '初中级部', '初中年级管理');
INSERT INTO `department` VALUES (9, '高一级部（赵华卿）', '高一年级管理');
INSERT INTO `department` VALUES (10, '高二级部（郭庆海）', '高二年级管理');
INSERT INTO `department` VALUES (11, '高三级部（卢翔远）', '高三年级管理');
INSERT INTO `department` VALUES (12, '财务科', '财务管理');
INSERT INTO `department` VALUES (13, '人事科', '人事管理');
INSERT INTO `department` VALUES (14, '教科处', '教科研管理');
INSERT INTO `department` VALUES (15, '团委（少先队）', '团委与少先队管理');
INSERT INTO `department` VALUES (16, '纪委办公室', '纪律检查管理');
INSERT INTO `department` VALUES (22, '摄影部', '专业摄影创作团队');
INSERT INTO `department` VALUES (23, '设计部', '平面设计与视觉创作');
INSERT INTO `department` VALUES (24, '艺术部', '艺术作品创作与展示');
INSERT INTO `department` VALUES (25, '媒体部', '数字媒体与影像制作');
INSERT INTO `department` VALUES (26, '策划部', '活动策划与内容运营');

-- ----------------------------
-- Table structure for followers
-- ----------------------------
DROP TABLE IF EXISTS `followers`;
CREATE TABLE `followers`  (
  `follower_id` int NOT NULL,
  `followed_id` int NOT NULL,
  PRIMARY KEY (`follower_id`, `followed_id`) USING BTREE,
  INDEX `followed_id`(`followed_id` ASC) USING BTREE,
  CONSTRAINT `followers_ibfk_1` FOREIGN KEY (`followed_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `followers_ibfk_2` FOREIGN KEY (`follower_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of followers
-- ----------------------------
INSERT INTO `followers` VALUES (3, 1);
INSERT INTO `followers` VALUES (6, 1);
INSERT INTO `followers` VALUES (15, 1);
INSERT INTO `followers` VALUES (36, 1);
INSERT INTO `followers` VALUES (37, 1);
INSERT INTO `followers` VALUES (1, 2);
INSERT INTO `followers` VALUES (4, 2);
INSERT INTO `followers` VALUES (5, 2);
INSERT INTO `followers` VALUES (6, 2);
INSERT INTO `followers` VALUES (10, 2);
INSERT INTO `followers` VALUES (24, 2);
INSERT INTO `followers` VALUES (25, 2);
INSERT INTO `followers` VALUES (26, 2);
INSERT INTO `followers` VALUES (32, 2);
INSERT INTO `followers` VALUES (34, 2);
INSERT INTO `followers` VALUES (38, 2);
INSERT INTO `followers` VALUES (10, 3);
INSERT INTO `followers` VALUES (12, 3);
INSERT INTO `followers` VALUES (16, 3);
INSERT INTO `followers` VALUES (27, 3);
INSERT INTO `followers` VALUES (29, 3);
INSERT INTO `followers` VALUES (38, 3);
INSERT INTO `followers` VALUES (10, 4);
INSERT INTO `followers` VALUES (35, 4);
INSERT INTO `followers` VALUES (37, 4);
INSERT INTO `followers` VALUES (10, 5);
INSERT INTO `followers` VALUES (19, 5);
INSERT INTO `followers` VALUES (20, 5);
INSERT INTO `followers` VALUES (24, 5);
INSERT INTO `followers` VALUES (25, 5);
INSERT INTO `followers` VALUES (11, 6);
INSERT INTO `followers` VALUES (17, 6);
INSERT INTO `followers` VALUES (36, 6);
INSERT INTO `followers` VALUES (39, 6);
INSERT INTO `followers` VALUES (40, 6);
INSERT INTO `followers` VALUES (1, 7);
INSERT INTO `followers` VALUES (6, 7);
INSERT INTO `followers` VALUES (25, 7);
INSERT INTO `followers` VALUES (26, 7);
INSERT INTO `followers` VALUES (30, 7);
INSERT INTO `followers` VALUES (33, 7);
INSERT INTO `followers` VALUES (10, 8);
INSERT INTO `followers` VALUES (11, 8);
INSERT INTO `followers` VALUES (12, 8);
INSERT INTO `followers` VALUES (16, 8);
INSERT INTO `followers` VALUES (30, 8);
INSERT INTO `followers` VALUES (32, 8);
INSERT INTO `followers` VALUES (34, 8);
INSERT INTO `followers` VALUES (2, 9);
INSERT INTO `followers` VALUES (22, 9);
INSERT INTO `followers` VALUES (23, 9);
INSERT INTO `followers` VALUES (25, 9);
INSERT INTO `followers` VALUES (37, 9);
INSERT INTO `followers` VALUES (23, 10);
INSERT INTO `followers` VALUES (25, 10);
INSERT INTO `followers` VALUES (33, 10);
INSERT INTO `followers` VALUES (40, 10);
INSERT INTO `followers` VALUES (1, 11);
INSERT INTO `followers` VALUES (3, 11);
INSERT INTO `followers` VALUES (14, 11);
INSERT INTO `followers` VALUES (18, 11);
INSERT INTO `followers` VALUES (20, 11);
INSERT INTO `followers` VALUES (24, 11);
INSERT INTO `followers` VALUES (27, 11);
INSERT INTO `followers` VALUES (30, 11);
INSERT INTO `followers` VALUES (33, 11);
INSERT INTO `followers` VALUES (39, 11);
INSERT INTO `followers` VALUES (18, 12);
INSERT INTO `followers` VALUES (19, 12);
INSERT INTO `followers` VALUES (31, 12);
INSERT INTO `followers` VALUES (36, 12);
INSERT INTO `followers` VALUES (6, 13);
INSERT INTO `followers` VALUES (11, 13);
INSERT INTO `followers` VALUES (15, 13);
INSERT INTO `followers` VALUES (16, 13);
INSERT INTO `followers` VALUES (20, 13);
INSERT INTO `followers` VALUES (23, 13);
INSERT INTO `followers` VALUES (31, 13);
INSERT INTO `followers` VALUES (33, 13);
INSERT INTO `followers` VALUES (34, 13);
INSERT INTO `followers` VALUES (3, 14);
INSERT INTO `followers` VALUES (34, 14);
INSERT INTO `followers` VALUES (8, 15);
INSERT INTO `followers` VALUES (12, 15);
INSERT INTO `followers` VALUES (17, 15);
INSERT INTO `followers` VALUES (19, 15);
INSERT INTO `followers` VALUES (20, 15);
INSERT INTO `followers` VALUES (29, 15);
INSERT INTO `followers` VALUES (34, 15);
INSERT INTO `followers` VALUES (39, 15);
INSERT INTO `followers` VALUES (2, 16);
INSERT INTO `followers` VALUES (4, 16);
INSERT INTO `followers` VALUES (7, 16);
INSERT INTO `followers` VALUES (37, 16);
INSERT INTO `followers` VALUES (8, 17);
INSERT INTO `followers` VALUES (14, 17);
INSERT INTO `followers` VALUES (15, 17);
INSERT INTO `followers` VALUES (25, 17);
INSERT INTO `followers` VALUES (38, 17);
INSERT INTO `followers` VALUES (23, 18);
INSERT INTO `followers` VALUES (26, 18);
INSERT INTO `followers` VALUES (30, 18);
INSERT INTO `followers` VALUES (38, 18);
INSERT INTO `followers` VALUES (40, 18);
INSERT INTO `followers` VALUES (14, 19);
INSERT INTO `followers` VALUES (24, 19);
INSERT INTO `followers` VALUES (27, 19);
INSERT INTO `followers` VALUES (31, 19);
INSERT INTO `followers` VALUES (40, 19);
INSERT INTO `followers` VALUES (22, 20);
INSERT INTO `followers` VALUES (28, 20);
INSERT INTO `followers` VALUES (29, 20);
INSERT INTO `followers` VALUES (37, 20);
INSERT INTO `followers` VALUES (40, 20);
INSERT INTO `followers` VALUES (3, 21);
INSERT INTO `followers` VALUES (12, 21);
INSERT INTO `followers` VALUES (16, 21);
INSERT INTO `followers` VALUES (20, 21);
INSERT INTO `followers` VALUES (38, 21);
INSERT INTO `followers` VALUES (19, 22);
INSERT INTO `followers` VALUES (13, 23);
INSERT INTO `followers` VALUES (24, 23);
INSERT INTO `followers` VALUES (30, 23);
INSERT INTO `followers` VALUES (33, 23);
INSERT INTO `followers` VALUES (34, 23);
INSERT INTO `followers` VALUES (39, 23);
INSERT INTO `followers` VALUES (1, 24);
INSERT INTO `followers` VALUES (18, 24);
INSERT INTO `followers` VALUES (28, 24);
INSERT INTO `followers` VALUES (8, 25);
INSERT INTO `followers` VALUES (21, 25);
INSERT INTO `followers` VALUES (27, 25);
INSERT INTO `followers` VALUES (29, 25);
INSERT INTO `followers` VALUES (1, 26);
INSERT INTO `followers` VALUES (11, 26);
INSERT INTO `followers` VALUES (12, 26);
INSERT INTO `followers` VALUES (27, 26);
INSERT INTO `followers` VALUES (39, 26);
INSERT INTO `followers` VALUES (40, 26);
INSERT INTO `followers` VALUES (3, 27);
INSERT INTO `followers` VALUES (11, 27);
INSERT INTO `followers` VALUES (21, 27);
INSERT INTO `followers` VALUES (24, 27);
INSERT INTO `followers` VALUES (26, 27);
INSERT INTO `followers` VALUES (38, 27);
INSERT INTO `followers` VALUES (22, 28);
INSERT INTO `followers` VALUES (24, 28);
INSERT INTO `followers` VALUES (33, 28);
INSERT INTO `followers` VALUES (40, 28);
INSERT INTO `followers` VALUES (1, 29);
INSERT INTO `followers` VALUES (2, 29);
INSERT INTO `followers` VALUES (16, 29);
INSERT INTO `followers` VALUES (27, 29);
INSERT INTO `followers` VALUES (30, 29);
INSERT INTO `followers` VALUES (35, 29);
INSERT INTO `followers` VALUES (40, 29);
INSERT INTO `followers` VALUES (5, 30);
INSERT INTO `followers` VALUES (17, 30);
INSERT INTO `followers` VALUES (19, 30);
INSERT INTO `followers` VALUES (26, 30);
INSERT INTO `followers` VALUES (1, 31);
INSERT INTO `followers` VALUES (9, 31);
INSERT INTO `followers` VALUES (15, 31);
INSERT INTO `followers` VALUES (20, 31);
INSERT INTO `followers` VALUES (34, 31);
INSERT INTO `followers` VALUES (35, 31);
INSERT INTO `followers` VALUES (1, 32);
INSERT INTO `followers` VALUES (9, 32);
INSERT INTO `followers` VALUES (10, 32);
INSERT INTO `followers` VALUES (12, 32);
INSERT INTO `followers` VALUES (13, 32);
INSERT INTO `followers` VALUES (25, 32);
INSERT INTO `followers` VALUES (28, 32);
INSERT INTO `followers` VALUES (31, 32);
INSERT INTO `followers` VALUES (33, 32);
INSERT INTO `followers` VALUES (37, 32);
INSERT INTO `followers` VALUES (4, 33);
INSERT INTO `followers` VALUES (6, 33);
INSERT INTO `followers` VALUES (8, 33);
INSERT INTO `followers` VALUES (11, 33);
INSERT INTO `followers` VALUES (23, 33);
INSERT INTO `followers` VALUES (3, 34);
INSERT INTO `followers` VALUES (8, 34);
INSERT INTO `followers` VALUES (10, 34);
INSERT INTO `followers` VALUES (16, 34);
INSERT INTO `followers` VALUES (21, 34);
INSERT INTO `followers` VALUES (27, 34);
INSERT INTO `followers` VALUES (31, 34);
INSERT INTO `followers` VALUES (39, 34);
INSERT INTO `followers` VALUES (3, 35);
INSERT INTO `followers` VALUES (13, 35);
INSERT INTO `followers` VALUES (26, 35);
INSERT INTO `followers` VALUES (2, 36);
INSERT INTO `followers` VALUES (6, 36);
INSERT INTO `followers` VALUES (7, 36);
INSERT INTO `followers` VALUES (9, 36);
INSERT INTO `followers` VALUES (13, 36);
INSERT INTO `followers` VALUES (15, 36);
INSERT INTO `followers` VALUES (31, 36);
INSERT INTO `followers` VALUES (39, 36);
INSERT INTO `followers` VALUES (6, 37);
INSERT INTO `followers` VALUES (8, 37);
INSERT INTO `followers` VALUES (11, 37);
INSERT INTO `followers` VALUES (30, 37);
INSERT INTO `followers` VALUES (33, 37);
INSERT INTO `followers` VALUES (39, 37);
INSERT INTO `followers` VALUES (12, 38);
INSERT INTO `followers` VALUES (20, 38);
INSERT INTO `followers` VALUES (29, 38);
INSERT INTO `followers` VALUES (34, 38);
INSERT INTO `followers` VALUES (2, 39);
INSERT INTO `followers` VALUES (5, 39);
INSERT INTO `followers` VALUES (6, 39);
INSERT INTO `followers` VALUES (26, 39);
INSERT INTO `followers` VALUES (28, 39);
INSERT INTO `followers` VALUES (29, 39);
INSERT INTO `followers` VALUES (32, 39);
INSERT INTO `followers` VALUES (38, 39);
INSERT INTO `followers` VALUES (2, 40);
INSERT INTO `followers` VALUES (7, 40);
INSERT INTO `followers` VALUES (15, 40);
INSERT INTO `followers` VALUES (18, 40);
INSERT INTO `followers` VALUES (20, 40);
INSERT INTO `followers` VALUES (23, 40);
INSERT INTO `followers` VALUES (31, 40);

-- ----------------------------
-- Table structure for gallery
-- ----------------------------
DROP TABLE IF EXISTS `gallery`;
CREATE TABLE `gallery`  (
  `id` int NOT NULL,
  `image_count` int NULL DEFAULT NULL,
  `cover_image_id` int NULL DEFAULT NULL,
  `is_published` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `cover_image_id`(`cover_image_id` ASC) USING BTREE,
  CONSTRAINT `gallery_ibfk_1` FOREIGN KEY (`id`) REFERENCES `content` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `gallery_ibfk_2` FOREIGN KEY (`cover_image_id`) REFERENCES `image` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gallery
-- ----------------------------
INSERT INTO `gallery` VALUES (56, 0, 63, 0);
INSERT INTO `gallery` VALUES (64, 0, NULL, 0);
INSERT INTO `gallery` VALUES (89, 2, 93, 0);
INSERT INTO `gallery` VALUES (100, 3, 101, 0);
INSERT INTO `gallery` VALUES (109, 2, 110, 0);
INSERT INTO `gallery` VALUES (136, 4, 137, 0);
INSERT INTO `gallery` VALUES (151, 2, 153, 0);
INSERT INTO `gallery` VALUES (169, 4, 170, 0);
INSERT INTO `gallery` VALUES (179, 2, 181, 0);
INSERT INTO `gallery` VALUES (221, 6, 185, 0);
INSERT INTO `gallery` VALUES (222, 4, 194, 0);
INSERT INTO `gallery` VALUES (223, 4, 191, 0);
INSERT INTO `gallery` VALUES (224, 5, 202, 0);
INSERT INTO `gallery` VALUES (225, 3, 201, 0);
INSERT INTO `gallery` VALUES (226, 4, 213, 0);
INSERT INTO `gallery` VALUES (227, 3, 208, 0);
INSERT INTO `gallery` VALUES (228, 3, 217, 0);
INSERT INTO `gallery` VALUES (229, 3, 215, 0);

-- ----------------------------
-- Table structure for image
-- ----------------------------
DROP TABLE IF EXISTS `image`;
CREATE TABLE `image`  (
  `id` int NOT NULL,
  `filename` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `filepath` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `file_hash` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `file_size` int NULL DEFAULT NULL,
  `file_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `width` int NULL DEFAULT NULL,
  `height` int NULL DEFAULT NULL,
  `gallery_id` int NULL DEFAULT NULL,
  `ai_status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `ai_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `ai_tags` json NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `filename`(`filename` ASC) USING BTREE,
  UNIQUE INDEX `ix_image_file_hash`(`file_hash` ASC) USING BTREE,
  INDEX `ix_image_ai_status`(`ai_status` ASC) USING BTREE,
  INDEX `image_ibfk_1`(`gallery_id` ASC) USING BTREE,
  CONSTRAINT `image_ibfk_1` FOREIGN KEY (`gallery_id`) REFERENCES `gallery` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `image_ibfk_2` FOREIGN KEY (`id`) REFERENCES `content` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of image
-- ----------------------------
INSERT INTO `image` VALUES (57, 'c7534778-6d5c-4b0c-8a5f-a715a91a9c20.jpg', 'uploads\\gallery_56\\c7534778-6d5c-4b0c-8a5f-a715a91a9c20.jpg', '3beae3ef0a56b94278b6431c7acee38d5f46df2513bcc40b9af97589bdc8715d', NULL, NULL, NULL, NULL, 64, 'pending', NULL, NULL);
INSERT INTO `image` VALUES (58, '3fbe40d3-3e5c-4878-8fec-c06c1c545ac7.jpg', 'uploads\\gallery_56\\3fbe40d3-3e5c-4878-8fec-c06c1c545ac7.jpg', '07e833ef3154baade3fd69188f32c075cb63ac5161e4d9222827ff30bb76cd9c', NULL, NULL, NULL, NULL, 64, 'pending', NULL, NULL);
INSERT INTO `image` VALUES (59, '43674b45-20fd-47a0-90a8-e4ccb0fdc3a4.jpg', 'uploads\\gallery_56\\43674b45-20fd-47a0-90a8-e4ccb0fdc3a4.jpg', 'cccd0345a0fbea5191bcfae714fd8e4d8c71a449c1bed33e241811cf43c0d7a5', NULL, NULL, NULL, NULL, 64, 'pending', NULL, NULL);
INSERT INTO `image` VALUES (60, 'df02b247-8df2-412b-b8cb-497c3bb9f8eb.jpg', 'uploads\\gallery_56\\df02b247-8df2-412b-b8cb-497c3bb9f8eb.jpg', '40c1383d860f9e6f3803626052dd89f0711e37216f1d91d470023e0bc90f6277', NULL, NULL, NULL, NULL, 64, 'pending', NULL, NULL);
INSERT INTO `image` VALUES (61, '67448043-5b84-477c-b54c-33fdd68c28c1.jpg', 'uploads\\gallery_56\\67448043-5b84-477c-b54c-33fdd68c28c1.jpg', 'a8c30c6d991cf2ef3fb684b9ca9d448056858215f2542062fb7c4a7d8885cf3c', NULL, NULL, NULL, NULL, 64, 'pending', NULL, NULL);
INSERT INTO `image` VALUES (62, '32f30843-6477-4c61-84f9-cb0d83a74e5d.jpg', 'uploads\\gallery_56\\32f30843-6477-4c61-84f9-cb0d83a74e5d.jpg', '34756d1ccb2dffcafd79f48621793b6962a67e8b1bde5a91f46b166685f67ec7', NULL, NULL, NULL, NULL, 64, 'pending', NULL, NULL);
INSERT INTO `image` VALUES (63, 'c8c83573-cc6c-470a-8280-cf3e0f266677.jpg', 'uploads\\gallery_56\\c8c83573-cc6c-470a-8280-cf3e0f266677.jpg', '28e89eef02bbc61361febf0315ebed5dc19c8e751954569a54f3c05ecf6d7f8c', NULL, NULL, NULL, NULL, 56, 'pending', NULL, NULL);
INSERT INTO `image` VALUES (93, 'ca2706fd-7fb0-4b27-8ecf-10f407bc1945.jpg', 'uploads\\gallery_89\\ca2706fd-7fb0-4b27-8ecf-10f407bc1945.jpg', '7b700b086c55596d7ce5c496211dc4a3a7bd379d2741e520823bc71216c2ca5a', NULL, NULL, NULL, NULL, 89, 'pending', NULL, NULL);
INSERT INTO `image` VALUES (94, '2e8608e3-9132-417b-89a8-db2d05bb562b.jpg', 'uploads\\gallery_89\\2e8608e3-9132-417b-89a8-db2d05bb562b.jpg', 'a3ee3d0ba99485102fa800b3ca2159e6cef128dd38e26229fe6edbc8254184bd', NULL, NULL, NULL, NULL, 89, 'pending', NULL, NULL);
INSERT INTO `image` VALUES (101, '224587f7-ece5-4be1-8a4d-09ecc41a1f77.jpg', 'uploads\\gallery_56\\df02b247-8df2-412b-b8cb-497c3bb9f8eb.jpg', NULL, NULL, NULL, NULL, NULL, 100, 'pending', NULL, NULL);
INSERT INTO `image` VALUES (102, '076c759b-0f5b-433d-b8fd-f09fa2b155ae.jpg', 'uploads\\gallery_56\\67448043-5b84-477c-b54c-33fdd68c28c1.jpg', NULL, NULL, NULL, NULL, NULL, 100, 'pending', NULL, NULL);
INSERT INTO `image` VALUES (103, 'a26f9495-ec90-4bc9-a057-4b0ecf3c1632.jpg', 'uploads\\gallery_100\\a26f9495-ec90-4bc9-a057-4b0ecf3c1632.jpg', '7a0c3ed5da3f19e1eed128a4533bb597ec9d5a7012fdb01b5572856436345e8d', NULL, NULL, NULL, NULL, 100, 'pending', NULL, NULL);
INSERT INTO `image` VALUES (110, 'f6e955b9-f467-4c66-8995-21db5b3534df.jpg', 'uploads\\gallery_104\\2e03f9fe-ce51-4ffc-a758-0b6ff2e22a78.jpg', NULL, NULL, NULL, NULL, NULL, 109, 'pending', NULL, NULL);
INSERT INTO `image` VALUES (111, '0bcd2f23-ed27-4d37-9055-fb31e48ff665.jpg', 'uploads\\gallery_109\\0bcd2f23-ed27-4d37-9055-fb31e48ff665.jpg', 'f7abf3c76f12ede02a65c85ee85a85d4c032fe248e8044b231071b3de230b9e6', NULL, NULL, NULL, NULL, 109, 'completed', '这张图片展示了一只停留在浅色背景上的翠绿色蜻蜓。蜻蜓展开翅膀，翅膀呈现半透明的淡黄色，身体细长，具有典型的昆虫形态。', '[\"蜻蜓\", \"昆虫\", \"动物\", \"自然\", \"绿色\", \"黄色\"]');
INSERT INTO `image` VALUES (137, '29eb8bbe-e48c-464e-b0ca-38e5e2fe02d6.jpg', 'uploads\\gallery_136\\29eb8bbe-e48c-464e-b0ca-38e5e2fe02d6.jpg', 'caab31608bc9acaa501a257bc25746d30064fe90ec957d0e8c9e54924f3632fb', NULL, NULL, NULL, NULL, 136, 'completed', '这是一幅中国古代人物画像，描绘了一位胡须浓密的男子，身着传统长袍，头系蓝色发带。整体画面呈现出一种庄重、肃穆的氛围，具有浓厚的历史文化气息。', '[\"中国古代人物\", \"历史画像\", \"传统服饰\", \"男性肖像\", \"棕色调\", \"文化艺术\"]');
INSERT INTO `image` VALUES (145, 'a83ad381-30f8-45e1-8e09-c9a20bd8cf97.jpg', 'uploads\\gallery_136\\a83ad381-30f8-45e1-8e09-c9a20bd8cf97.jpg', 'a0ecebbcc2d4043bf1f228a86d3d6024f4aa363c06bbc470c169d73df33576e8', NULL, NULL, NULL, NULL, 136, 'pending', NULL, NULL);
INSERT INTO `image` VALUES (146, '9e34290b-d4c7-4bb1-ad55-2bafc1cc62af.jpg', 'uploads\\gallery_136\\9e34290b-d4c7-4bb1-ad55-2bafc1cc62af.jpg', 'b62f7acac73128dff8ac3128a5b9a04ab6f1b737abb1465e7d9af4174e641214', NULL, NULL, NULL, NULL, 136, 'pending', NULL, NULL);
INSERT INTO `image` VALUES (147, '1aee438b-5e6d-4a38-83f6-5ce2e0d13341.jpg', 'uploads\\gallery_136\\1aee438b-5e6d-4a38-83f6-5ce2e0d13341.jpg', 'fcbfa2887e3ed6474e2e51a5b5ec9716a786bc1798055c2bdb6a8ccfbaa14236', NULL, NULL, NULL, NULL, 136, 'pending', NULL, NULL);
INSERT INTO `image` VALUES (153, 'ee74f897-2af2-470c-b8d5-f374a96dd079.jpg', 'uploads/gallery_151/ee74f897-2af2-470c-b8d5-f374a96dd079.jpg', 'eabe155h9nynq', NULL, NULL, NULL, NULL, 151, 'pending', NULL, NULL);
INSERT INTO `image` VALUES (154, '47ccab51-7896-4957-847c-c7cf947515b8.jpg', 'uploads/gallery_151/47ccab51-7896-4957-847c-c7cf947515b8.jpg', '491dc407blkmdh', NULL, NULL, NULL, NULL, 151, 'pending', NULL, NULL);
INSERT INTO `image` VALUES (170, '6895447f-b220-4ac3-a2c7-b3c73151a916.jpg', 'uploads/gallery_169/6895447f-b220-4ac3-a2c7-b3c73151a916.jpg', '2b859e854yy1gn', NULL, NULL, NULL, NULL, 169, 'pending', NULL, NULL);
INSERT INTO `image` VALUES (171, '3eb872b9-1c9e-4622-ad80-5e57f5985781.jpg', 'uploads/gallery_169/3eb872b9-1c9e-4622-ad80-5e57f5985781.jpg', '3dacd853guwcrh', NULL, NULL, NULL, NULL, 169, 'pending', NULL, NULL);
INSERT INTO `image` VALUES (175, 'd52df633-b16f-423b-bcc4-cd802180071c.jpg', 'uploads/gallery_169/d52df633-b16f-423b-bcc4-cd802180071c.jpg', '64d6ae975bs1za', NULL, NULL, NULL, NULL, 169, 'pending', NULL, NULL);
INSERT INTO `image` VALUES (178, '60222fbe-c099-4088-8680-d1bacb7aadf9.jpg', 'uploads/gallery_169/60222fbe-c099-4088-8680-d1bacb7aadf9.jpg', '66ac9e85jb2fpu', NULL, NULL, NULL, NULL, 169, 'pending', NULL, NULL);
INSERT INTO `image` VALUES (180, '395fe7fb-7615-4e7c-8f27-87d399bde117.jpg', 'uploads/gallery_179/395fe7fb-7615-4e7c-8f27-87d399bde117.jpg', '7fd71bd6xpns29', NULL, NULL, NULL, NULL, 179, 'pending', NULL, NULL);
INSERT INTO `image` VALUES (181, '93d67763-9733-465a-96be-c51c733fff5b.jpg', 'uploads/gallery_179/93d67763-9733-465a-96be-c51c733fff5b.jpg', '35e1170c1fl0ar', NULL, NULL, NULL, NULL, 179, 'pending', NULL, NULL);
INSERT INTO `image` VALUES (182, 'img_1751903637215671_45_0.jpg', 'uploads\\images\\img_1751903637215671_45_0.jpg', 'f7f397bd8d0e4c840c0b8b943885db577f5c095369296c0c660e7889dde5b223', 99697, 'image/jpeg', 1200, 800, 221, 'completed', '这是一幅师德师风建设作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (183, 'img_1751903638977339_45_1.jpg', 'uploads\\images\\img_1751903638977339_45_1.jpg', '99e2a47bf5017313e6091e089b18e150fdff5ec7e95ef7deffbbc5f304f58894', 120945, 'image/jpeg', 1200, 800, 221, 'completed', '这是一幅3D渲染作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (184, 'img_1751903640111286_45_2.jpg', 'uploads\\images\\img_1751903640111286_45_2.jpg', '969feb043b3c3c626108f4782e4c1acf8cf004ffb12a2f179fa47b8b2c28ec5d', 126463, 'image/jpeg', 1200, 800, 221, 'completed', '这是一幅后勤与安全保障作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (185, 'img_1751903642777868_45_3.jpg', 'uploads\\images\\img_1751903642777868_45_3.jpg', 'f32fe2e1b3e2ec5082e0a4f239815958f4dc4bae3abe5cd50d9795b62e18db1b', 126081, 'image/jpeg', 1200, 800, 221, 'completed', '这是一幅师德师风建设作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (186, 'img_1751903644533186_45_4.jpg', 'uploads\\images\\img_1751903644533186_45_4.jpg', '536d8b30adea1d257a4694d5fd3bed3d435bb58129493d4a4c6b1c486ddd4509', 284713, 'image/jpeg', 1200, 800, NULL, 'completed', '这是一幅海报设计作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (187, 'img_1751903661427547_45_5.jpg', 'uploads\\images\\img_1751903661427547_45_5.jpg', '456a50864411cd944114f7bcd929a6a0181b7fc875c57543d3e2a87352f9d701', 54454, 'image/jpeg', 1200, 800, 221, 'completed', '这是一幅学生组织与社团活动作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (188, 'img_1751903663469462_45_6.jpg', 'uploads\\images\\img_1751903663469462_45_6.jpg', '39e378776b9810e6d5b173c3188eb4228274cff35b14bc0fe3205ec489559a69', 81846, 'image/jpeg', 1200, 800, 221, 'completed', '这是一幅街头摄影作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (189, 'img_1751903664945169_45_7.jpg', 'uploads\\images\\img_1751903664945169_45_7.jpg', 'd82465bd7c1b273a3cd95ec07e891035946b8f8f3315ee577fdb66e7f33e3d66', 123926, 'image/jpeg', 1200, 800, NULL, 'completed', '这是一幅党建引领作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (190, 'img_1751903667417314_46_0.jpg', 'uploads\\images\\img_1751903667417314_46_0.jpg', 'b58d120388960a8aeaa1005a21ddd3f9386298567368fc1000905d0028075fa2', 76331, 'image/jpeg', 1200, 800, 223, 'completed', '这是一幅建筑摄影作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (191, 'img_1751903670093434_46_1.jpg', 'uploads\\images\\img_1751903670093434_46_1.jpg', '7176ec3421e10046a9e68c453b9f3f3eddbd6bce78ca808c27eee5640c3cbbc2', 35071, 'image/jpeg', 1200, 800, 223, 'completed', '这是一幅街头摄影作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (192, 'img_1751903671665610_46_2.jpg', 'uploads\\images\\img_1751903671665610_46_2.jpg', 'c3a2c9fea006dbf6fbc2b6892ee5483530ceef28748d414e59af5a5074e703a2', 86576, 'image/jpeg', 1200, 800, 223, 'completed', '这是一幅建筑摄影作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (193, 'img_1751903674290217_46_3.jpg', 'uploads\\images\\img_1751903674290217_46_3.jpg', 'bc67fafeca36547116e5cca71ae4abb9ae9db63a139d610e5a0e4c49a2d8c243', 293042, 'image/jpeg', 1200, 800, 222, 'completed', '这是一幅校园风光与设施作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (194, 'img_1751903679044997_46_4.jpg', 'uploads\\images\\img_1751903679044997_46_4.jpg', '55a81ae1357143d2749847163891f02f43ba8f45b6193c8f01ef7754aecd8110', 233876, 'image/jpeg', 1200, 800, 222, 'completed', '这是一幅街头摄影作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (195, 'img_1751903680710456_46_5.jpg', 'uploads\\images\\img_1751903680710456_46_5.jpg', '7a579ce6628ea9ee42de364a1ea6971ecb745b7673fc6d1122599a7781d11afb', 113725, 'image/jpeg', 1200, 800, 222, 'completed', '这是一幅校园风光与设施作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (196, 'img_1751903682473272_46_6.jpg', 'uploads\\images\\img_1751903682473272_46_6.jpg', '632f1a87c46d96f147331f19777e772cb6b85d945d93b72386b49fdba39a6b24', 151503, 'image/jpeg', 1200, 800, 222, 'completed', '这是一幅招生与宣传作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (197, 'img_1751903684215519_46_7.jpg', 'uploads\\images\\img_1751903684215519_46_7.jpg', '700706ef634f9d0b20b2e643891f3e6bc1f3b1aeee096105f6127a03de72af9e', 97241, 'image/jpeg', 1200, 800, 223, 'completed', '这是一幅水彩画作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (198, 'img_1751903685797232_47_0.jpg', 'uploads\\images\\img_1751903685797232_47_0.jpg', 'fa082e90b2daaf2b68dcdc070cb013259573b378f9e8e74cce06bba15582a16c', 112986, 'image/jpeg', 1200, 800, 224, 'completed', '这是一幅教学资源与成果作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (199, 'img_1751903687457469_47_1.jpg', 'uploads\\images\\img_1751903687457469_47_1.jpg', '2201668de2816fd207e385d04989c39abc5555c2e1ac57e7c48aa5829f3c5556', 149779, 'image/jpeg', 1200, 800, 225, 'completed', '这是一幅包装设计作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (200, 'img_1751903690204963_47_2.jpg', 'uploads\\images\\img_1751903690204963_47_2.jpg', 'e0a035130f578e57eda84cb047ae9fe18d1e4d5f5ed88e062560d21697e8d730', 188147, 'image/jpeg', 1200, 800, 224, 'completed', '这是一幅动画作品作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (201, 'img_1751903693590568_47_3.jpg', 'uploads\\images\\img_1751903693590568_47_3.jpg', '5779b432471156308de376799e79e269c33e7a925c1cef70f932d075a44c4ef1', 79388, 'image/jpeg', 1200, 800, 225, 'completed', '这是一幅动画作品作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (202, 'img_1751903696241217_47_4.jpg', 'uploads\\images\\img_1751903696241217_47_4.jpg', '1bc19ef4f8a00e049ce04618b21c466bd98384ed9d8a663f44bd23f27b036325', 42876, 'image/jpeg', 1200, 800, 224, 'completed', '这是一幅校园风光与设施作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (203, 'img_1751903698022612_47_5.jpg', 'uploads\\images\\img_1751903698022612_47_5.jpg', 'b607b342c84a487dbf4d977886178f6759176399b8ee6f0b6c3afc154c5f4d78', 158300, 'image/jpeg', 1200, 800, 224, 'completed', '这是一幅对外交流与合作作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (204, 'img_1751903700647245_47_6.jpg', 'uploads\\images\\img_1751903700647245_47_6.jpg', 'a6c2570d28b34b4c6efa25062626aeca975d60d3dd7142e58be5019e6ea88672', 82972, 'image/jpeg', 1200, 800, 224, 'completed', '这是一幅常规课堂教学作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (205, 'img_1751903702778351_47_7.jpg', 'uploads\\images\\img_1751903702778351_47_7.jpg', 'c9fa0a08cbeff1b7ae5f0b8cc123a9edbe27abe25e450e54b6f4d98b9b143bb9', 124128, 'image/jpeg', 1200, 800, 225, 'completed', '这是一幅3D渲染作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (206, 'img_1751903704349807_48_0.jpg', 'uploads\\images\\img_1751903704349807_48_0.jpg', '2c1ae996a469386200a841af6be83b1d717ae0bf24e3c17b2da98bc16863943a', 196816, 'image/jpeg', 1200, 800, NULL, 'completed', '这是一幅家庭摄影作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (207, 'img_1751903706126542_48_1.jpg', 'uploads\\images\\img_1751903706126542_48_1.jpg', '149e0c3befaec9a042d902645869e51dc4f08b8a2bea2160eb9b311e77a88246', 284570, 'image/jpeg', 1200, 800, 226, 'completed', '这是一幅招生与宣传作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (208, 'img_1751903708211612_48_2.jpg', 'uploads\\images\\img_1751903708211612_48_2.jpg', 'de2faa2a2d69fca25d2ff3998b1c1b7ba61519cc44877f280336cf0bcfc93164', 126929, 'image/jpeg', 1200, 800, 227, 'completed', '这是一幅包装设计作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (209, 'img_1751903710042938_48_3.jpg', 'uploads\\images\\img_1751903710042938_48_3.jpg', 'b7b67b0ae80a30845a207cabf2adc4653cc20d71032984fa9c9afdc36b4d447f', 167384, 'image/jpeg', 1200, 800, 227, 'completed', '这是一幅水彩画作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (210, 'img_1751903711948615_48_4.jpg', 'uploads\\images\\img_1751903711948615_48_4.jpg', '005b4f154874915e5fdaabf8303b418e12d155785e3ed407bf676c39037d911b', 90236, 'image/jpeg', 1200, 800, 227, 'completed', '这是一幅建筑摄影作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (211, 'img_1751903714609383_48_5.jpg', 'uploads\\images\\img_1751903714609383_48_5.jpg', '03df3250d01bc2acf19d9f417768644630ce8bfab5d53b0c624d4e971f3bfa21', 153606, 'image/jpeg', 1200, 800, 226, 'completed', '这是一幅文化景观与氛围作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (212, 'img_1751903718420127_48_6.jpg', 'uploads\\images\\img_1751903718420127_48_6.jpg', 'd11604718122637ec15f3495fb0aa4baeb5c38737048650b5048de2c9b6631e2', 140774, 'image/jpeg', 1200, 800, 226, 'completed', '这是一幅制度与治理作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (213, 'img_1751903720057328_48_7.jpg', 'uploads\\images\\img_1751903720057328_48_7.jpg', '1b312dd870a0595a53e9d2b27a2507b15875bd4a008b39dc5dde3d9aaaa9b700', 79255, 'image/jpeg', 1200, 800, 226, 'completed', '这是一幅党建引领作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (214, 'img_1751903722712491_49_0.jpg', 'uploads\\images\\img_1751903722712491_49_0.jpg', '7303abebf6a563b516ea286918d2fca54dda9555582932192918725de3b29aec', 38816, 'image/jpeg', 1200, 800, NULL, 'completed', '这是一幅后勤与安全保障作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (215, 'img_1751903724170131_49_1.jpg', 'uploads\\images\\img_1751903724170131_49_1.jpg', '713dcfe3d31f249262047795cd4686d84ee343180c9cc4c2201b12082489c551', 79127, 'image/jpeg', 1200, 800, 229, 'completed', '这是一幅校园风光与设施作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (216, 'img_1751903725758945_49_2.jpg', 'uploads\\images\\img_1751903725758945_49_2.jpg', '15d3c957ca560c7a5f637f82b8f0fcef239a1c1cde57bd28ca6c110a70bc2688', 146518, 'image/jpeg', 1200, 800, 228, 'completed', '这是一幅荣誉与风采作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (217, 'img_1751903727292414_49_3.jpg', 'uploads\\images\\img_1751903727292414_49_3.jpg', '492774d0e0dfea081746891fe251b85d706c25399a8ac78e27de0a0f11fd5f27', 110676, 'image/jpeg', 1200, 800, 228, 'completed', '这是一幅学生组织与社团活动作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (218, 'img_1751903728939526_49_4.jpg', 'uploads\\images\\img_1751903728939526_49_4.jpg', 'b94f44f365aa8720f51f393e61d25307dd2654da9519c4b4ca4dcbc051445606', 51535, 'image/jpeg', 1200, 800, 229, 'completed', '这是一幅水彩画作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (219, 'img_1751903734006457_49_6.jpg', 'uploads\\images\\img_1751903734006457_49_6.jpg', 'b5742a49bbfd72b0a2f65578bfe2c38c315f11dc808ee089157be6ad6a86aeb6', 136978, 'image/jpeg', 1200, 800, 228, 'completed', '这是一幅宠物摄影作品，具有很高的艺术价值。', NULL);
INSERT INTO `image` VALUES (220, 'img_1751903736183054_49_7.jpg', 'uploads\\images\\img_1751903736183054_49_7.jpg', 'a68dc22111bb493f360fef680b3af0ddef90faf896cf78dd2870776df439ccf4', 174788, 'image/jpeg', 1200, 800, 229, 'completed', '这是一幅身心健康发展作品，具有很高的艺术价值。', NULL);

-- ----------------------------
-- Table structure for link
-- ----------------------------
DROP TABLE IF EXISTS `link`;
CREATE TABLE `link`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '链接标题',
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '链接地址',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '链接描述',
  `is_active` tinyint(1) NULL DEFAULT NULL COMMENT '是否启用',
  `sort_order` int NULL DEFAULT NULL COMMENT '排序权重，数字越大越靠前',
  `created_at` datetime NULL DEFAULT (now()),
  `updated_at` datetime NULL DEFAULT (now()),
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ix_link_id`(`id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of link
-- ----------------------------
INSERT INTO `link` VALUES (1, '曲阜师大附中', 'http://fz.qfnu.edu.cn', '曲阜师范大学附属中小学官网', 1, 10, '2025-06-21 12:15:13', '2025-06-21 12:15:13');
INSERT INTO `link` VALUES (2, '曲阜师范大学', 'https://example.com/tools', '曲阜师范大学官网', 1, 9, '2025-06-21 12:15:13', '2025-06-21 12:15:13');
INSERT INTO `link` VALUES (3, '新应用平台', '#', '曲阜师大附中新应用平台', 1, 8, '2025-06-21 12:15:13', '2025-06-21 12:15:13');
INSERT INTO `link` VALUES (4, '本地AI平台', 'http://192.168.5.117:3000', '曲阜师大附中本地化大语言平台', 1, 7, '2025-06-21 12:15:13', '2025-06-21 12:15:13');
INSERT INTO `link` VALUES (5, 'AI教育创新实践案例', '/曲阜师大附中 AI教育创新实践案例.html', '曲阜师大附中AI教育创新实践案例', 1, 6, '2025-06-21 12:15:13', '2025-06-21 12:15:13');
INSERT INTO `link` VALUES (6, 'AI绘画平台', 'http://192.168.5.117:7860', '曲阜师大附中AI绘画平台', 1, 5, '2025-06-21 12:15:13', '2025-06-21 12:15:13');
INSERT INTO `link` VALUES (7, '虚位以待', '#', '欢迎链接', 1, 4, '2025-06-21 12:15:13', '2025-06-21 12:15:13');
INSERT INTO `link` VALUES (8, '虚位以待', '#', '欢迎链接', 1, 3, '2025-06-21 12:15:13', '2025-06-21 12:15:13');

-- ----------------------------
-- Table structure for setting
-- ----------------------------
DROP TABLE IF EXISTS `setting`;
CREATE TABLE `setting`  (
  `key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  PRIMARY KEY (`key`) USING BTREE,
  UNIQUE INDEX `ix_setting_key`(`key` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of setting
-- ----------------------------
INSERT INTO `setting` VALUES ('allowed_file_types', 'jpg,jpeg,png,gif,webp,tiff,svg,bmp');
INSERT INTO `setting` VALUES ('enable_comments', 'true');
INSERT INTO `setting` VALUES ('enable_registration', 'true');
INSERT INTO `setting` VALUES ('featured_content_count', '10');
INSERT INTO `setting` VALUES ('items_per_page', '10');
INSERT INTO `setting` VALUES ('llm_model', 'gemma3:27b');
INSERT INTO `setting` VALUES ('max_upload_size', '10485760');
INSERT INTO `setting` VALUES ('ollama_api', 'http://192.168.5.117:11434');
INSERT INTO `setting` VALUES ('program_developer', 'The Bright Red Star Team.');
INSERT INTO `setting` VALUES ('site_description', 'OurGallery图片分享平台');
INSERT INTO `setting` VALUES ('site_logo', '');
INSERT INTO `setting` VALUES ('site_name', 'OurGallery');

-- ----------------------------
-- Table structure for tag
-- ----------------------------
DROP TABLE IF EXISTS `tag`;
CREATE TABLE `tag`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ix_tag_name`(`name` ASC) USING BTREE,
  INDEX `ix_tag_id`(`id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 146 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of tag
-- ----------------------------
INSERT INTO `tag` VALUES (139, '4K');
INSERT INTO `tag` VALUES (3, 'AI');
INSERT INTO `tag` VALUES (132, '专业');
INSERT INTO `tag` VALUES (133, '业余');
INSERT INTO `tag` VALUES (68, '中国人物');
INSERT INTO `tag` VALUES (80, '中国传统');
INSERT INTO `tag` VALUES (57, '中国传统绘画');
INSERT INTO `tag` VALUES (84, '中国古代人物');
INSERT INTO `tag` VALUES (65, '中国文化');
INSERT INTO `tag` VALUES (72, '中国绘画');
INSERT INTO `tag` VALUES (98, '中国风');
INSERT INTO `tag` VALUES (81, '中年男子');
INSERT INTO `tag` VALUES (27, '中考');
INSERT INTO `tag` VALUES (111, '乡村');
INSERT INTO `tag` VALUES (40, '互动');
INSERT INTO `tag` VALUES (41, '交流');
INSERT INTO `tag` VALUES (104, '人像');
INSERT INTO `tag` VALUES (102, '人文');
INSERT INTO `tag` VALUES (94, '人物');
INSERT INTO `tag` VALUES (58, '人物肖像');
INSERT INTO `tag` VALUES (131, '优雅');
INSERT INTO `tag` VALUES (10, '会议');
INSERT INTO `tag` VALUES (91, '传统文化');
INSERT INTO `tag` VALUES (67, '传统服饰');
INSERT INTO `tag` VALUES (64, '传统绘画');
INSERT INTO `tag` VALUES (7, '体测');
INSERT INTO `tag` VALUES (60, '儒家文化');
INSERT INTO `tag` VALUES (140, '全景');
INSERT INTO `tag` VALUES (32, '公告');
INSERT INTO `tag` VALUES (120, '写实');
INSERT INTO `tag` VALUES (66, '写实风格');
INSERT INTO `tag` VALUES (6, '军训');
INSERT INTO `tag` VALUES (30, '决策');
INSERT INTO `tag` VALUES (21, '出访');
INSERT INTO `tag` VALUES (121, '创意');
INSERT INTO `tag` VALUES (5, '创新');
INSERT INTO `tag` VALUES (15, '办公');
INSERT INTO `tag` VALUES (51, '动物');
INSERT INTO `tag` VALUES (29, '励志');
INSERT INTO `tag` VALUES (48, '单色');
INSERT INTO `tag` VALUES (85, '单色背景');
INSERT INTO `tag` VALUES (95, '历史');
INSERT INTO `tag` VALUES (59, '历史人物');
INSERT INTO `tag` VALUES (99, '历史画像');
INSERT INTO `tag` VALUES (82, '历史绘画');
INSERT INTO `tag` VALUES (137, '原片');
INSERT INTO `tag` VALUES (25, '参观');
INSERT INTO `tag` VALUES (56, '古代人物');
INSERT INTO `tag` VALUES (78, '古代服饰');
INSERT INTO `tag` VALUES (118, '古典');
INSERT INTO `tag` VALUES (26, '合同');
INSERT INTO `tag` VALUES (136, '后期');
INSERT INTO `tag` VALUES (110, '城市');
INSERT INTO `tag` VALUES (38, '声明');
INSERT INTO `tag` VALUES (124, '复古');
INSERT INTO `tag` VALUES (107, '夜景');
INSERT INTO `tag` VALUES (55, '孔子');
INSERT INTO `tag` VALUES (17, '学考');
INSERT INTO `tag` VALUES (129, '宁静');
INSERT INTO `tag` VALUES (13, '安全');
INSERT INTO `tag` VALUES (76, '官帽');
INSERT INTO `tag` VALUES (9, '实验');
INSERT INTO `tag` VALUES (113, '山景');
INSERT INTO `tag` VALUES (86, '平面插画');
INSERT INTO `tag` VALUES (116, '建筑');
INSERT INTO `tag` VALUES (106, '彩色');
INSERT INTO `tag` VALUES (42, '待分析');
INSERT INTO `tag` VALUES (20, '感恩');
INSERT INTO `tag` VALUES (35, '成果');
INSERT INTO `tag` VALUES (134, '手机');
INSERT INTO `tag` VALUES (119, '抽象');
INSERT INTO `tag` VALUES (12, '拓展');
INSERT INTO `tag` VALUES (37, '招标');
INSERT INTO `tag` VALUES (142, '摄影');
INSERT INTO `tag` VALUES (23, '教学');
INSERT INTO `tag` VALUES (4, '文件');
INSERT INTO `tag` VALUES (89, '文化艺术');
INSERT INTO `tag` VALUES (108, '日出');
INSERT INTO `tag` VALUES (109, '日落');
INSERT INTO `tag` VALUES (123, '时尚');
INSERT INTO `tag` VALUES (50, '昆虫');
INSERT INTO `tag` VALUES (45, '暖色调');
INSERT INTO `tag` VALUES (33, '来访');
INSERT INTO `tag` VALUES (2, '校友');
INSERT INTO `tag` VALUES (90, '棕色');
INSERT INTO `tag` VALUES (101, '棕色调');
INSERT INTO `tag` VALUES (114, '森林');
INSERT INTO `tag` VALUES (24, '比赛');
INSERT INTO `tag` VALUES (1, '毕业');
INSERT INTO `tag` VALUES (14, '汇演');
INSERT INTO `tag` VALUES (96, '汉服');
INSERT INTO `tag` VALUES (130, '活力');
INSERT INTO `tag` VALUES (126, '浪漫');
INSERT INTO `tag` VALUES (112, '海边');
INSERT INTO `tag` VALUES (125, '温馨');
INSERT INTO `tag` VALUES (11, '游学');
INSERT INTO `tag` VALUES (18, '爱国');
INSERT INTO `tag` VALUES (79, '版画风格');
INSERT INTO `tag` VALUES (141, '特写');
INSERT INTO `tag` VALUES (117, '现代');
INSERT INTO `tag` VALUES (143, '生活');
INSERT INTO `tag` VALUES (100, '男性肖像');
INSERT INTO `tag` VALUES (135, '相机');
INSERT INTO `tag` VALUES (93, '石像');
INSERT INTO `tag` VALUES (36, '社团');
INSERT INTO `tag` VALUES (127, '神秘');
INSERT INTO `tag` VALUES (16, '科技');
INSERT INTO `tag` VALUES (46, '简约');
INSERT INTO `tag` VALUES (71, '米色');
INSERT INTO `tag` VALUES (43, '红棕色');
INSERT INTO `tag` VALUES (70, '红色');
INSERT INTO `tag` VALUES (62, '红色长袍');
INSERT INTO `tag` VALUES (44, '纯色背景');
INSERT INTO `tag` VALUES (69, '绘画风格');
INSERT INTO `tag` VALUES (53, '绿色');
INSERT INTO `tag` VALUES (83, '肖像');
INSERT INTO `tag` VALUES (61, '肖像画');
INSERT INTO `tag` VALUES (74, '胡须');
INSERT INTO `tag` VALUES (52, '自然');
INSERT INTO `tag` VALUES (47, '色彩');
INSERT INTO `tag` VALUES (122, '艺术');
INSERT INTO `tag` VALUES (31, '节日');
INSERT INTO `tag` VALUES (115, '花卉');
INSERT INTO `tag` VALUES (39, '获奖');
INSERT INTO `tag` VALUES (75, '蓝色');
INSERT INTO `tag` VALUES (49, '蜻蜓');
INSERT INTO `tag` VALUES (144, '街头');
INSERT INTO `tag` VALUES (34, '表扬');
INSERT INTO `tag` VALUES (145, '设计');
INSERT INTO `tag` VALUES (19, '评比');
INSERT INTO `tag` VALUES (22, '通知');
INSERT INTO `tag` VALUES (8, '采购');
INSERT INTO `tag` VALUES (97, '长者');
INSERT INTO `tag` VALUES (63, '长胡须');
INSERT INTO `tag` VALUES (73, '长袍');
INSERT INTO `tag` VALUES (87, '长须');
INSERT INTO `tag` VALUES (88, '雕像');
INSERT INTO `tag` VALUES (92, '雕塑');
INSERT INTO `tag` VALUES (128, '震撼');
INSERT INTO `tag` VALUES (77, '面部特写');
INSERT INTO `tag` VALUES (103, '风景');
INSERT INTO `tag` VALUES (138, '高清');
INSERT INTO `tag` VALUES (28, '高考');
INSERT INTO `tag` VALUES (54, '黄色');
INSERT INTO `tag` VALUES (105, '黑白');

-- ----------------------------
-- Table structure for topic
-- ----------------------------
DROP TABLE IF EXISTS `topic`;
CREATE TABLE `topic`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `slug` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `is_active` tinyint(1) NULL DEFAULT NULL,
  `is_featured` tinyint(1) NULL DEFAULT NULL,
  `created_at` datetime NULL DEFAULT (now()),
  `updated_at` datetime NULL DEFAULT (now()),
  `cover_image_id` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ix_topic_name`(`name` ASC) USING BTREE,
  UNIQUE INDEX `ix_topic_slug`(`slug` ASC) USING BTREE,
  INDEX `ix_topic_id`(`id` ASC) USING BTREE,
  INDEX `ix_topic_is_active`(`is_active` ASC) USING BTREE,
  INDEX `ix_topic_is_featured`(`is_featured` ASC) USING BTREE,
  INDEX `cover_image_id`(`cover_image_id` ASC) USING BTREE,
  CONSTRAINT `topic_ibfk_1` FOREIGN KEY (`cover_image_id`) REFERENCES `image` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of topic
-- ----------------------------
INSERT INTO `topic` VALUES (1, '自然风光', 'natural-scenery', '汇集最美的自然风光图集，包含山川、湖泊、森林等各种自然景观', 1, 1, '2025-06-22 14:37:14', '2025-07-05 10:45:33', NULL);
INSERT INTO `topic` VALUES (2, '城市印象', 'city-impressions', '记录城市的美好瞬间，从繁华街区到静谧小巷', 1, 1, '2025-06-22 14:37:14', '2025-07-05 10:47:12', NULL);
INSERT INTO `topic` VALUES (3, '人文摄影', 'human-photography', '捕捉人文情怀，展现生活中的温暖时刻', 1, 0, '2025-06-22 14:37:14', '2025-07-05 10:48:00', NULL);
INSERT INTO `topic` VALUES (4, '建筑艺术', 'architecture-art', '欣赏建筑之美，从古典到现代的建筑艺术', 1, 0, '2025-06-22 14:37:14', '2025-07-05 10:47:32', NULL);
INSERT INTO `topic` VALUES (5, '抽象艺术', 'abstract-art', '探索抽象艺术的无限可能，感受色彩与形状的魅力', 1, 0, '2025-06-22 14:37:14', '2025-07-05 10:47:18', NULL);
INSERT INTO `topic` VALUES (6, '春日物语', 'spring-stories', '捕捉春天的美好时光，记录生机盎然的春日景象', 1, 0, '2025-07-07 15:53:56', '2025-07-07 15:53:56', NULL);
INSERT INTO `topic` VALUES (7, '人像艺术', 'portrait-art', '人物肖像的艺术表达，情感与美的结合', 1, 0, '2025-07-07 15:53:56', '2025-07-07 15:53:56', NULL);
INSERT INTO `topic` VALUES (8, '自然之美', 'natural-beauty', '大自然的壮丽景色，风光摄影的极致展现', 1, 0, '2025-07-07 15:53:56', '2025-07-07 15:53:56', NULL);
INSERT INTO `topic` VALUES (9, '创意设计', 'creative-design', '设计师的创意作品，视觉艺术的无限可能', 1, 0, '2025-07-07 15:53:56', '2025-07-07 15:53:56', NULL);
INSERT INTO `topic` VALUES (10, '黑白世界', 'black-and-white', '黑白摄影的独特魅力，经典与现代的碰撞', 1, 0, '2025-07-07 15:53:56', '2025-07-07 15:53:56', NULL);

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `hashed_password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `role` enum('USER','VIP','ADMIN') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `is_active` tinyint(1) NULL DEFAULT NULL,
  `is_superuser` tinyint(1) NULL DEFAULT NULL,
  `created_at` datetime NULL DEFAULT (now()),
  `updated_at` datetime NULL DEFAULT NULL,
  `bio` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `department_id` int NULL DEFAULT NULL,
  `full_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ix_user_email`(`email` ASC) USING BTREE,
  UNIQUE INDEX `ix_user_username`(`username` ASC) USING BTREE,
  INDEX `department_id`(`department_id` ASC) USING BTREE,
  INDEX `ix_user_id`(`id` ASC) USING BTREE,
  CONSTRAINT `user_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `department` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 50 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'admin', 'admin@gallery.com', '$2b$12$OvZEPhHBzW1tKfcySWDw3.5Jrcut6b3VHyEoAnaqk3PwVkj6uME/i', 'ADMIN', 1, 1, '2025-06-20 15:53:12', '2025-06-22 15:50:36', '系统管理员', 5, NULL);
INSERT INTO `user` VALUES (2, 'photographer1', 'photo1@gallery.com', '$2b$12$pASSXzwXdG5ihWNUOWEe5uvktqng8tfxHQDaxbWxkziZfkU5gs34a', 'VIP', 1, 0, '2025-06-20 15:53:12', '2025-06-20 15:53:12', '专业摄影师', 1, NULL);
INSERT INTO `user` VALUES (3, 'designer1', 'design1@gallery.com', '$2b$12$QCoBtDCCayY6qXouSBB2M.0Tyr2mGlYhYCiDYjensJWTZ9XfiXkv.', 'USER', 1, 0, '2025-06-20 15:53:12', '2025-06-20 15:53:12', 'UI/UX设计师', 2, NULL);
INSERT INTO `user` VALUES (4, 'artist1', 'art1@gallery.com', '$2b$12$vYjkT2Ys7KB0u8pwimY1t..KLKch0xcVGqoqSCfzU1ntrBYC0Q4UW', 'VIP', 1, 0, '2025-06-20 15:53:12', '2025-06-20 15:53:12', '数字艺术家', 3, NULL);
INSERT INTO `user` VALUES (5, 'user1', 'user1@gallery.com', '$2b$12$vAtB5Iq51/WW5oydn/6xxeHIGbFjg3lJEmgR5nnud7UXTmTveAlAq', 'USER', 1, 0, '2025-06-20 15:53:12', '2025-06-20 15:53:12', '摄影爱好者', 4, NULL);
INSERT INTO `user` VALUES (6, 'user2', 'user2@gallery.com', '$2b$12$36WvbdJqHwOa8VrBCt.BNu57p8bNiz/TA/lh/cXOPNmKN2FlZLRsy', 'USER', 1, 0, '2025-06-20 15:53:13', '2025-06-20 15:53:13', '设计爱好者', 5, NULL);
INSERT INTO `user` VALUES (7, 'user001', 'user001@gallery.com', '$2b$12$2/7d.tK5YQAlfG7yDtCr0eBofwFktvwsSQoA2qJoh/bpy4oBT5O2G', 'USER', 1, 0, '2025-06-20 16:42:50', '2025-06-20 16:42:50', '我是张伟创作者，热爱摄影和艺术创作。', 4, NULL);
INSERT INTO `user` VALUES (8, 'user002', 'user002@gallery.com', '$2b$12$eQqF3LnJijRr5nZ.VN6Th.c5EQbaWI3fyXDjF9i.zMn5HIok7HC5C', 'USER', 1, 0, '2025-06-20 16:42:50', '2025-06-20 16:42:50', '我是李娜设计师，热爱摄影和艺术创作。', 4, NULL);
INSERT INTO `user` VALUES (9, 'user003', 'user003@gallery.com', '$2b$12$aMPYoTzOy5kjA030xwuN/OTwPuDJ7RLtHzGhavi7jALtBeN5wo92q', 'USER', 1, 0, '2025-06-20 16:42:50', '2025-06-25 15:43:41', '我是王芳爱好者，热爱摄影和艺术创作。', 5, NULL);
INSERT INTO `user` VALUES (10, 'user004', 'user004@gallery.com', '$2b$12$QoB/UQoUz5Wr6d7sJG3OWOkWXsWA5QqVIniYzqmfBRUNsAQApG2PC', 'USER', 1, 0, '2025-06-20 16:42:50', '2025-06-21 11:51:52', '我是刘强摄影师，热爱摄影和艺术创作。', 4, NULL);
INSERT INTO `user` VALUES (11, 'user005', 'user005@gallery.com', '$2b$12$WSHCRN4kSUCkvvzHuP1q.eoIHHVZppGCWOjru8292qohYHekxmWAa', 'USER', 1, 0, '2025-06-20 16:42:50', '2025-06-20 16:42:50', '我是陈静设计师，热爱摄影和艺术创作。', 4, NULL);
INSERT INTO `user` VALUES (12, 'user006', 'user006@gallery.com', '$2b$12$jqaaCt6wquBDOZ/r.V3APOydCaHfoCjADsE4CZVhrChZExcdCOrpO', 'USER', 1, 0, '2025-06-20 16:42:50', '2025-06-20 16:42:51', '我是杨洋爱好者，热爱摄影和艺术创作。', 2, NULL);
INSERT INTO `user` VALUES (13, 'user007', 'user007@gallery.com', '$2b$12$wFyXwiT8WqLHPLrCwu8yxOA/0qnWeAu3eEd83QYUR6cuPFwHsC71q', 'USER', 1, 0, '2025-06-20 16:42:51', '2025-06-20 16:42:51', '我是赵雷摄影师，热爱摄影和艺术创作。', 2, NULL);
INSERT INTO `user` VALUES (14, 'user008', 'user008@gallery.com', '$2b$12$Z1p.xP94GbW6cYd9Oge75edHZDI.//UOc63Fr7LxmG5mXZqXxdUvu', 'USER', 1, 0, '2025-06-20 16:42:51', '2025-06-20 16:42:51', '我是黄敏创作者，热爱摄影和艺术创作。', 5, NULL);
INSERT INTO `user` VALUES (15, 'user009', 'user009@gallery.com', '$2b$12$nRULpjcSB2Obxgu9FSwdiub7.EwoPXEWRZXRzYqATmTmWBXKP1zVC', 'USER', 1, 0, '2025-06-20 16:42:51', '2025-06-20 16:42:51', '我是周杰爱好者，热爱摄影和艺术创作。', 3, NULL);
INSERT INTO `user` VALUES (16, 'user010', 'user010@gallery.com', '$2b$12$BX.cFMlYN9KYnGnu0waoMOpJDUpFGq1dkoVVDBBYnDq2y4tqhqjcO', 'USER', 1, 0, '2025-06-20 16:42:51', '2025-06-20 16:42:51', '我是吴丽设计师，热爱摄影和艺术创作。', 5, NULL);
INSERT INTO `user` VALUES (17, 'user011', 'user011@gallery.com', '$2b$12$4g2x5h9veTjEJIuZTv/NO.3yLpbFVHcG24iBZF7NevkpF.0G5zNMK', 'USER', 1, 0, '2025-06-20 16:42:51', '2025-06-20 16:42:51', '我是徐明摄影师，热爱摄影和艺术创作。', 5, NULL);
INSERT INTO `user` VALUES (18, 'user012', 'user012@gallery.com', '$2b$12$7HDIBSzXQgaKfBwhDDr1QOemaC.cX50XidSh.Xuzqfj9fK7n204ga', 'USER', 1, 0, '2025-06-20 16:42:51', '2025-06-20 16:42:51', '我是朱红设计师，热爱摄影和艺术创作。', 4, NULL);
INSERT INTO `user` VALUES (19, 'user013', 'user013@gallery.com', '$2b$12$mNkozm2gji3FET6UaTANe.y4hcUaZXy2eq3ojisqNM5F.guxEZkaG', 'USER', 1, 0, '2025-06-20 16:42:51', '2025-06-20 16:42:52', '我是林峰创作者，热爱摄影和艺术创作。', 1, NULL);
INSERT INTO `user` VALUES (20, 'user014', 'user014@gallery.com', '$2b$12$JKozOBi9BopyeFnw1n5Vh.vR7xUyjnMrOUyyv5c3Ve.U3ETgGFlJK', 'USER', 1, 0, '2025-06-20 16:42:52', '2025-06-20 16:42:52', '我是何超爱好者，热爱摄影和艺术创作。', 1, NULL);
INSERT INTO `user` VALUES (21, 'user015', 'user015@gallery.com', '$2b$12$iG4xjRe7/jv5I5cXWquz0e3vkRZv.2H426kmppTPN.fY4bqemHlcK', 'USER', 1, 0, '2025-06-20 16:42:52', '2025-06-20 16:42:52', '我是郭宁设计师，热爱摄影和艺术创作。', 3, NULL);
INSERT INTO `user` VALUES (22, 'user016', 'user016@gallery.com', '$2b$12$OQR256jjnyVc9WskqCzMWu62HnUVJazVowtIQSlcaqJxgx62/9BOG', 'USER', 1, 0, '2025-06-20 16:42:52', '2025-06-20 16:42:52', '我是马丽设计师，热爱摄影和艺术创作。', 5, NULL);
INSERT INTO `user` VALUES (23, 'user017', 'user017@gallery.com', '$2b$12$1LxVfbKtEDpgq/URwRiUq.ebcGaug6whk3upSJxPHFnUcyRxMU.pG', 'USER', 1, 0, '2025-06-20 16:42:52', '2025-06-20 16:42:52', '我是孙涛创作者，热爱摄影和艺术创作。', 4, NULL);
INSERT INTO `user` VALUES (24, 'user018', 'user018@gallery.com', '$2b$12$mld1OUqvigOpNHwyh2Ah1OdsextbJY6.QQETzeE/hkJ9K0iP4wTQS', 'USER', 1, 0, '2025-06-20 16:42:52', '2025-06-20 16:42:52', '我是韩雪摄影师，热爱摄影和艺术创作。', 4, NULL);
INSERT INTO `user` VALUES (25, 'user019', 'user019@gallery.com', '$2b$12$s60jYE5UcWATEFJNzMbePe2jJmoRVe8X27cX0F2iZtmuZ/bSP.hsa', 'USER', 1, 0, '2025-06-20 16:42:52', '2025-06-20 16:42:52', '我是梁斌爱好者，热爱摄影和艺术创作。', 3, NULL);
INSERT INTO `user` VALUES (26, 'user020', 'user020@gallery.com', '$2b$12$d1iYMcEELqXKiCg/TmxoS.WdeT6xvpvx6ctjNmmk2IfEWR3/SOgdm', 'USER', 1, 0, '2025-06-20 16:42:52', '2025-06-20 16:42:53', '我是谢娟艺术家，热爱摄影和艺术创作。', 4, NULL);
INSERT INTO `user` VALUES (27, 'user021', 'user021@gallery.com', '$2b$12$UCB.JDaxL9rz2k5N5VRkDuJxopIdqRlyrIdf.PsdW/dfXBvZYE67K', 'USER', 1, 0, '2025-06-20 16:42:53', '2025-06-20 16:42:53', '我是罗华创作者，热爱摄影和艺术创作。', 2, NULL);
INSERT INTO `user` VALUES (28, 'user022', 'user022@gallery.com', '$2b$12$vezf005WVmqoq9NorZggtu9VYdg8d/41f.1jAQDzh1nnx/9.6YkR.', 'USER', 1, 0, '2025-06-20 16:42:53', '2025-06-20 16:42:53', '我是高鹏艺术家，热爱摄影和艺术创作。', 1, NULL);
INSERT INTO `user` VALUES (29, 'user023', 'user023@gallery.com', '$2b$12$2G9wH/RSOHHv6OPzMnMcEOlSR9A0NsqXFNkjFqSCP5rCzJ90J9Q16', 'USER', 1, 0, '2025-06-20 16:42:53', '2025-06-20 16:42:53', '我是郑霞爱好者，热爱摄影和艺术创作。', 3, NULL);
INSERT INTO `user` VALUES (30, 'user024', 'user024@gallery.com', '$2b$12$ZnwidFgE8xBUKgfvpBWEjOnsFTScRElkM7ZdmD4suVQdk8LQ1wpC2', 'USER', 1, 0, '2025-06-20 16:42:53', '2025-06-20 16:42:53', '我是梁宇摄影师，热爱摄影和艺术创作。', 2, NULL);
INSERT INTO `user` VALUES (31, 'user025', 'user025@gallery.com', '$2b$12$x0vONf/Q7MMOgnPvI83VhecJo4UbuQ1PcNOxexb6tZqfc87NqjnLW', 'USER', 1, 0, '2025-06-20 16:42:53', '2025-06-20 16:42:53', '我是谭婷摄影师，热爱摄影和艺术创作。', 3, NULL);
INSERT INTO `user` VALUES (32, 'testuser01', 'test01@gallery.com', '$2b$12$o96rGLvzcs0cYbjE5D395uT/jxSMeTBM0X/xsqaUZ/YCWHW/daOsW', 'USER', 1, 0, '2025-06-20 16:43:48', NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (33, 'testuser02', 'test02@gallery.com', '$2b$12$CbM1ROD0yPM3C7NuJgMjNOh69ko3YULJbjDiA.lBE3Ww1/Dwwzp1e', 'USER', 1, 0, '2025-06-20 16:43:48', NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (34, 'testuser03', 'test03@gallery.com', '$2b$12$.pmHx.lAxGhmFFSrCBC/c.sX8qALNt9fxBYr0Q2CoH1LQsxA6m2sy', 'USER', 1, 0, '2025-06-20 16:43:48', NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (35, 'testuser04', 'test04@gallery.com', '$2b$12$e8m66aKXuCcHAGntD3nZGe9liTfbVoL7gGqRsX3nstLWuCv9in/sm', 'USER', 1, 0, '2025-06-20 16:43:49', NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (36, 'testuser05', 'test05@gallery.com', '$2b$12$1vtWjh2o.u2JmkOxYoX0cOh12SsH9vn9asHQW1ocjghiMcxG.mNbW', 'USER', 1, 0, '2025-06-20 16:43:49', NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (37, 'testuser06', 'test06@gallery.com', '$2b$12$uxIR8zLgvvBQNOurblQhi.wo7Awyrf0gEb37X1WshdSlpcvETT.le', 'USER', 1, 0, '2025-06-20 16:43:49', NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (38, 'testuser07', 'test07@gallery.com', '$2b$12$tM1t1aC0.rQavO0plFV/LO8LTj.dL7fGZI2GZB.pkDu8SVMlM8DTy', 'USER', 1, 0, '2025-06-20 16:43:49', NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (39, 'testuser08', 'test08@gallery.com', '$2b$12$nPpRdvAejx3pYbsjvkxc3.oOf2AOOz5HLjXlk46AimhQJNDRzp2nK', 'USER', 1, 0, '2025-06-20 16:43:49', NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (40, 'testuser09', 'test09@gallery.com', '$2b$12$sTkdZdJeeGu/Y/vSRG8Abu8c0ommDoqm.cuFEoogQMSrFgfKW4vYa', 'USER', 1, 0, '2025-06-20 16:43:49', NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (44, 'testuser123', 'testuser123@example.com', '$2b$12$01EcThfbQvKhm3Wy1kxLiOvywVnxHIL94pEd.qXbhSsi54LXeWYdK', 'USER', 1, 0, '2025-06-27 00:34:01', NULL, NULL, NULL, NULL);
INSERT INTO `user` VALUES (45, 'photographer_zhang', 'zhang@gallery.com', '$2b$12$5Bp9NmjdoDMMD7PuNq04SeZBbNLhnfdkhWgJ7rDIFE8033vm4IPiS', 'USER', 1, 0, '2025-07-07 15:53:56', '2025-07-07 15:53:56', '专注于风光摄影10年，擅长捕捉自然之美。作品曾在多个摄影展览中展出。', 22, NULL);
INSERT INTO `user` VALUES (46, 'designer_li', 'li@gallery.com', '$2b$12$xFec9j4oCam4M8t4QIHKbuqLQWw3H91hmPYcCw2Adq/cCvC3XQS.C', 'USER', 1, 0, '2025-07-07 15:53:56', '2025-07-07 15:53:56', '创意设计师，专注于品牌视觉设计。喜欢用色彩和创意传达情感。', 23, NULL);
INSERT INTO `user` VALUES (47, 'artist_wang', 'wang@gallery.com', '$2b$12$53PzoOvShI5xreNYpG31LuO6M9a4AZV9DWKZp5bGJOOL7dGAolfpq', 'USER', 1, 0, '2025-07-07 15:53:56', '2025-07-07 15:53:57', '数字艺术创作者，擅长3D建模和数字绘画。热爱探索艺术与技术的结合。', 24, NULL);
INSERT INTO `user` VALUES (48, 'street_photographer', 'liu@gallery.com', '$2b$12$zsvMQssLV6PTWJdS5N/gtuWeYV6M6.lYDKfZgChr7c5MghHtogzsS', 'USER', 1, 0, '2025-07-07 15:53:57', '2025-07-07 15:53:57', '街头摄影爱好者，善于捕捉城市生活的真实瞬间。', 25, NULL);
INSERT INTO `user` VALUES (49, 'portrait_master', 'chen@gallery.com', '$2b$12$42flL0P1L5pJhZVDdknBJuV2hCRe9ZxEgD/Hf6DhaySbOtQp6PdXu', 'USER', 1, 0, '2025-07-07 15:53:57', '2025-07-07 15:53:57', '专业人像摄影师，擅长捕捉人物的情感表达和内在美。', 22, NULL);

-- ----------------------------
-- Table structure for user_follows
-- ----------------------------
DROP TABLE IF EXISTS `user_follows`;
CREATE TABLE `user_follows`  (
  `follower_id` int NOT NULL,
  `followed_id` int NOT NULL,
  `created_at` datetime NULL DEFAULT (now()),
  PRIMARY KEY (`follower_id`, `followed_id`) USING BTREE,
  INDEX `followed_id`(`followed_id` ASC) USING BTREE,
  CONSTRAINT `user_follows_ibfk_1` FOREIGN KEY (`followed_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `user_follows_ibfk_2` FOREIGN KEY (`follower_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_follows
-- ----------------------------
INSERT INTO `user_follows` VALUES (16, 2, '2025-06-30 16:39:59');
INSERT INTO `user_follows` VALUES (16, 40, '2025-06-30 16:40:15');
INSERT INTO `user_follows` VALUES (25, 44, '2025-07-05 15:08:47');

SET FOREIGN_KEY_CHECKS = 1;
