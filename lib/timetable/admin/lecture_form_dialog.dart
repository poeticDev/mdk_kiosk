import 'package:flutter/material.dart';
import 'package:mdk_kiosk/common/component/custom_dialog.dart';
import 'package:mdk_kiosk/common/component/custom_text_form_field.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/common/const/style.dart';
import 'package:mdk_kiosk/timetable/model/lecture.dart';

/// 강의 생성/수정 폼 다이얼로그
///
/// 강의 정보를 입력받아 생성하거나 수정하는 다이얼로그입니다.
/// [lecture]가 null이면 생성 모드, null이 아니면 수정 모드로 동작합니다.
class LectureFormDialog extends StatefulWidget {
  final Lecture? lecture;
  final Function(Lecture) onSave;

  const LectureFormDialog({super.key, this.lecture, required this.onSave});

  @override
  State<LectureFormDialog> createState() => _LectureFormDialogState();
}

class _LectureFormDialogState extends State<LectureFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _lectureNameController;
  late TextEditingController _instructorNameController;
  late TimeOfDay _startAt;
  late TimeOfDay _endAt;
  late Weekday _selectedWeekday;
  late int _selectedColorIndex;

  bool get _isEditMode => widget.lecture != null;

  @override
  void initState() {
    super.initState();
    final lecture = widget.lecture;
    _lectureNameController = TextEditingController(
      text: lecture?.lectureName ?? '',
    );
    _instructorNameController = TextEditingController(
      text: lecture?.instructorName ?? '',
    );
    _startAt = lecture?.startAt ?? const TimeOfDay(hour: 9, minute: 0);
    _endAt = lecture?.endAt ?? const TimeOfDay(hour: 10, minute: 0);
    _selectedWeekday = lecture?.weekday ?? Weekday.monday;
    _selectedColorIndex = lecture?.colorIndex ?? 0;
  }

  @override
  void dispose() {
    _lectureNameController.dispose();
    _instructorNameController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay initialTime = isStart ? _startAt : _endAt;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: NORMAL_BLUE,
              onPrimary: WHITE_TEXT_COLOR,
              surface: BG_COLOR,
              onSurface: TEXT_COLOR,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startAt = picked;
        } else {
          _endAt = picked;
        }
      });
    }
  }

  bool _validateTimeRange() {
    final startMinutes = _startAt.hour * 60 + _startAt.minute;
    final endMinutes = _endAt.hour * 60 + _endAt.minute;
    return endMinutes > startMinutes;
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      if (!_validateTimeRange()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('종료 시간은 시작 시간보다 늦어야 합니다.'),
            backgroundColor: WARNING_RED,
          ),
        );
        return;
      }

      final lecture = Lecture(
        id: widget.lecture?.id ?? 0,
        lectureName: _lectureNameController.text.trim(),
        instructorName: _instructorNameController.text.trim(),
        weekday: _selectedWeekday,
        startAt: _startAt,
        endAt: _endAt,
        colorIndex: _selectedColorIndex,
      );

      widget.onSave(lecture);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: _isEditMode ? '강의 수정' : '강의 추가',
      widthRatio: 0.5,
      heightRatio: 0.7,
      content: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 강의명 (필수)
                CustomTextFormField(
                  title: '강의명 *',
                  hintText: '강의명을 입력하세요',
                  initialValue: _lectureNameController.text,
                  onChanged: (value) => _lectureNameController.text = value,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '강의명은 필수 입력 항목입니다.';
                    }
                    return null;
                  },
                  errorText: null,
                ),
                const SizedBox(height: 16),

                // 교수명 (선택)
                CustomTextFormField(
                  title: '교수명',
                  hintText: '교수명을 입력하세요 (선택)',
                  initialValue: _instructorNameController.text,
                  onChanged: (value) => _instructorNameController.text = value,
                ),
                const SizedBox(height: 16),

                // 요일 선택
                _buildDropdown<Weekday>(
                  title: '요일',
                  value: _selectedWeekday,
                  items: Weekday.values,
                  itemLabel: (weekday) => weekdays[weekday.index],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedWeekday = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // 시작 시간
                _buildTimeSelector(
                  title: '시작 시간',
                  time: _startAt,
                  onTap: () => _selectTime(context, true),
                ),
                const SizedBox(height: 16),

                // 종료 시간
                _buildTimeSelector(
                  title: '종료 시간',
                  time: _endAt,
                  onTap: () => _selectTime(context, false),
                ),
                const SizedBox(height: 16),

                // 색상 선택
                _buildColorSelector(),
                const SizedBox(height: 32),

                // 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: TEXT_COLOR,
                        fixedSize: const Size(120, 48),
                      ),
                      child: const Text('취소', style: DIALOG_BTN_TEXT_STYLE),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CHECK_GREEN,
                        foregroundColor: WHITE_TEXT_COLOR,
                        fixedSize: const Size(120, 48),
                      ),
                      child: Text(
                        _isEditMode ? '수정' : '추가',
                        style: DIALOG_BTN_TEXT_STYLE.copyWith(
                          color: WHITE_TEXT_COLOR,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String title,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: TEXT_COLOR,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: INPUT_BG_COLOR,
            border: Border.all(color: INPUT_BORDER_COLOR),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            style: const TextStyle(color: TEXT_COLOR, fontSize: 14.0),
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel(item)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector({
    required String title,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: TEXT_COLOR,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6.0),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: INPUT_BG_COLOR,
              border: Border.all(color: INPUT_BORDER_COLOR),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(time),
                  style: const TextStyle(color: TEXT_COLOR, fontSize: 14.0),
                ),
                const Icon(Icons.access_time, color: BODY_TEXT_COLOR),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '색상',
          style: TextStyle(
            color: TEXT_COLOR,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: List.generate(LECTURE_BG_COLORS.length, (index) {
            final isSelected = _selectedColorIndex == index;
            return InkWell(
              onTap: () {
                setState(() => _selectedColorIndex = index);
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: LECTURE_BG_COLORS[index],
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: isSelected ? TEXT_COLOR : INPUT_BORDER_COLOR,
                    width: isSelected ? 3.0 : 1.0,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: TEXT_COLOR)
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }
}
