import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/common/const/style.dart';
import 'package:mdk_kiosk/common/util/data/updaters.dart';
import 'package:mdk_kiosk/timetable/admin/lecture_form_dialog.dart';
import 'package:mdk_kiosk/timetable/data/timetable_repository.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';

/// 시간표 관리자 화면
///
/// 현재 강의실(roomId)의 시간표를 CRUD 방식으로 관리합니다.
/// EditableTimetableRepository를 통해 로컬 DB에 접근합니다.
class TimetableAdminScreen extends ConsumerStatefulWidget {
  const TimetableAdminScreen({super.key});

  @override
  ConsumerState<TimetableAdminScreen> createState() =>
      _TimetableAdminScreenState();
}

class _TimetableAdminScreenState extends ConsumerState<TimetableAdminScreen> {
  List<Lecture> _lectures = [];
  bool _isLoading = true;
  String? _errorMessage;

  EditableTimetableRepository get _repository =>
      GetIt.I<EditableTimetableRepository>();

  @override
  void initState() {
    super.initState();
    _loadLectures();
  }

  /// 강의 목록 로드
  Future<void> _loadLectures() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _repository.refresh();
      final lectures = _repository.getLectures();
      setState(() {
        _lectures = lectures;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '강의 목록을 불러오는데 실패했습니다: $e';
      });
    }
  }

  /// 새 강의 생성
  Future<void> _createLecture(Lecture lecture) async {
    try {
      await _repository.createLecture(lecture);
      await _loadLectures();
      _triggerTimetableUpdate();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('강의가 추가되었습니다.'),
            backgroundColor: CHECK_GREEN,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('강의 추가 실패: $e'), backgroundColor: WARNING_RED),
        );
      }
    }
  }

  /// 기존 강의 수정
  Future<void> _updateLecture(Lecture lecture) async {
    try {
      await _repository.updateLecture(lecture);
      await _loadLectures();
      _triggerTimetableUpdate();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('강의가 수정되었습니다.'),
            backgroundColor: CHECK_GREEN,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('강의 수정 실패: $e'), backgroundColor: WARNING_RED),
        );
      }
    }
  }

  /// 강의 삭제
  Future<void> _deleteLecture(int id) async {
    final confirmed = await _showDeleteConfirmationDialog();
    if (!confirmed) return;

    try {
      await _repository.deleteLecture(id);
      await _loadLectures();
      _triggerTimetableUpdate();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('강의가 삭제되었습니다.'),
            backgroundColor: CHECK_GREEN,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('강의 삭제 실패: $e'), backgroundColor: WARNING_RED),
        );
      }
    }
  }

  /// 삭제 확인 다이얼로그
  Future<bool> _showDeleteConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BG_COLOR,
        title: const Text('강의 삭제', style: DIALOG_TITLE_TEXT_STYLE),
        content: const Text('정말 이 강의를 삭제하시겠습니까?', style: BODY_TEXT_STYLE),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소', style: DIALOG_BTN_TEXT_STYLE),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              '삭제',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
                color: WARNING_RED,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 시간표 업데이트 트리거
  void _triggerTimetableUpdate() {
    ref.read(timetableUpdater.notifier).state = DateTime.now();
  }

  /// 강의 추가/수정 다이얼로그 표시
  void _showLectureFormDialog({Lecture? lecture}) {
    showDialog<void>(
      context: context,
      builder: (context) => LectureFormDialog(
        lecture: lecture,
        onSave: lecture == null ? _createLecture : _updateLecture,
      ),
    );
  }

  /// 요일별로 강의 그룹화
  Map<Weekday, List<Lecture>> _groupLecturesByWeekday() {
    final Map<Weekday, List<Lecture>> grouped = {};
    for (final weekday in Weekday.values) {
      grouped[weekday] = [];
    }
    for (final lecture in _lectures) {
      grouped[lecture.weekday]!.add(lecture);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('시간표 관리'),
        titleTextStyle: BODY_TEXT_STYLE.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadLectures,
            icon: const Icon(Icons.refresh, color: TEXT_COLOR),
            tooltip: '새로고침',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLectureFormDialog(),
        backgroundColor: NORMAL_BLUE,
        child: const Icon(Icons.add, color: WHITE_TEXT_COLOR),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: NORMAL_BLUE));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: WARNING_RED),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: BODY_TEXT_STYLE,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLectures,
              style: ElevatedButton.styleFrom(backgroundColor: NORMAL_BLUE),
              child: const Text(
                '다시 시도',
                style: TextStyle(color: WHITE_TEXT_COLOR),
              ),
            ),
          ],
        ),
      );
    }

    if (_lectures.isEmpty) {
      return _buildEmptyState();
    }

    return _buildLectureList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 80,
            color: Color.alphaBlend(
              BODY_TEXT_COLOR.withValues(alpha: 0.5),
              BG_COLOR,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '등록된 강의가 없습니다',
            style: BODY_TEXT_STYLE.copyWith(
              fontSize: 18,
              color: BODY_TEXT_COLOR.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '우측 하단 + 버튼을 눌러 강의를 추가하세요',
            style: BODY_TEXT_STYLE.copyWith(
              color: BODY_TEXT_COLOR.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLectureList() {
    final grouped = _groupLecturesByWeekday();
    final weekdaysWithLectures = Weekday.values
        .where((weekday) => grouped[weekday]!.isNotEmpty)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: weekdaysWithLectures.length,
      itemBuilder: (context, index) {
        final weekday = weekdaysWithLectures[index];
        final lectures = grouped[weekday]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 요일 헤더
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '${weekdays[weekday.index]}요일',
                style: TITLE_TEXT_STYLE.copyWith(fontSize: 18),
              ),
            ),
            // 강의 카드 목록
            ...lectures.map((lecture) => _buildLectureCard(lecture)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildLectureCard(Lecture lecture) {
    final colorIndex = lecture.colorIndex.clamp(
      0,
      LECTURE_BG_COLORS.length - 1,
    );
    final bgColor = LECTURE_BG_COLORS[colorIndex];

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      color: bgColor,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: BORDER_COLOR, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // 시간 표시
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '${_formatTime(lecture.startAt)}\n~${_formatTime(lecture.endAt)}',
                style: LECTURE_SUBTITLE_TEXT_STYLE.copyWith(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            // 강의 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lecture.lectureName,
                    style: LECTURE_TITLE_TEXT_STYLE,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (lecture.instructorName.isNotEmpty)
                    Text(
                      lecture.instructorName,
                      style: LECTURE_SUBTITLE_TEXT_STYLE,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // 액션 버튼
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _showLectureFormDialog(lecture: lecture),
                  icon: const Icon(Icons.edit, color: TEXT_COLOR),
                  iconSize: 20,
                  tooltip: '수정',
                ),
                IconButton(
                  onPressed: () => _deleteLecture(lecture.id),
                  icon: const Icon(Icons.delete, color: WARNING_RED),
                  iconSize: 20,
                  tooltip: '삭제',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
