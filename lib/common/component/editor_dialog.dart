import 'dart:math';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mdk_kiosk/common/component/custom_dialog.dart';
import 'package:mdk_kiosk/common/component/custom_text_form_field.dart';
import 'package:mdk_kiosk/common/component/custom_toast.dart';
import 'package:mdk_kiosk/common/const/colors.dart';
import 'package:mdk_kiosk/common/const/style.dart';
import 'package:mdk_kiosk/common/util/data/global_data.dart';
import 'package:mdk_kiosk/common/util/data/model/button.dart';
import 'package:mdk_kiosk/common/util/data/model/button_with_page.dart';
import 'package:mdk_kiosk/common/util/app_editor_mode.dart';
import 'package:mdk_kiosk/common/util/data/drift.dart';

enum EquipType { video, audio, etc }

class EditorWrapper extends StatelessWidget {
  final Widget child;
  final Widget dialog;
  final String? buttonName;
  final String? fixedName;
  final bool disableChildInteraction; // 자식 위젯 터치 차단 옵션

  EditorWrapper({
    super.key,
    required this.child,
    required this.dialog,
    this.buttonName,
    this.fixedName,
    this.disableChildInteraction = true, // 기본값: 터치 차단
  });

  factory EditorWrapper.basicInfo({
    required Widget child,
  }) {
    return EditorWrapper(dialog: BasicInfoDialog(), child: child);
  }

  factory EditorWrapper.button({
    required Widget child,
  }) {
    return EditorWrapper(dialog: ButtonEditorDialog(), child: child);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (appEditorManager.isEditorModeOn) {
          showDialog(
            context: context,
            builder: (context) {
              return dialog;
            },
          );
        }
      },
      child: appEditorManager.isEditorModeOn && disableChildInteraction
          ? AbsorbPointer(child: child) // ✅ 에디터 모드에서 자식 위젯 터치 차단
          : child,
    );
  }
}

class BasicInfoDialog extends StatefulWidget {
  const BasicInfoDialog({super.key});

  @override
  State<BasicInfoDialog> createState() => _BasicInfoDialogState();
}

class _BasicInfoDialogState extends State<BasicInfoDialog> {
  final db = GetIt.I<AppDatabase>();

  /// 1. 강의실 정보
  String roomId = globalData.roomId;
  String roomName = globalData.roomName;
  String titleText = globalData.titleText;
  String wifiName = globalData.wifiName;

  /// 2. 태블릿
  int myOscPort = globalData.myOscPort;

  /// 3. 서버
  String serverIp = globalData.serverIp;
  int serverOscPort = globalData.serverOscPort;
  int serverMqttPort = globalData.serverMqttPort;
  String serverMqttId = globalData.serverMqttId;
  String serverMqttPassword = globalData.serverMqttPassword;

  @override
  void initState() {
    super.initState();
  }

  Widget _BasicInfoEditor({Key? key}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomTextFormField(
          title: '강의실 Id',
          hintText: '0+건물번호 3자리+강의실번호 4자리, ex: 0-004-0101 = 4동 0101호',
          initialValue: roomId,
          onChanged: (inputText) {
            roomId = inputText;
          },
        ),
        SizedBox(height: 20.0),
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                title: '강의실 이름',
                hintText: '000동 0000호',
                initialValue: roomName,
                onChanged: (inputText) {
                  roomName = inputText;
                },
              ),
            ),
            SizedBox(width: 24),
            Expanded(
              child: CustomTextFormField(
                title: '헤더 텍스트',
                hintText: '헤더 우측 표시되는 텍스트',
                initialValue: titleText,
                onChanged: (inputText) {
                  titleText = inputText;
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 20.0),
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                title: '와이파이명',
                hintText: '와이파이 SSID',
                initialValue: wifiName,
                onChanged: (inputText) {
                  wifiName = inputText;
                },
              ),
            ),
            SizedBox(width: 24),
            Expanded(
              child: CustomTextFormField(
                title: '태블릿 OSC 포트',
                hintText: '보통 3000',
                initialValue: myOscPort.toString(),
                textInputType: TextInputType.number,
                onChanged: (inputText) {
                  myOscPort = int.parse(inputText);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 20.0),
        CustomTextFormField(
          title: '서버 IP',
          hintText: '서버 IP',
          initialValue: serverIp,
          onChanged: (inputText) {
            serverIp = inputText;
          },
        ),
        SizedBox(height: 20.0),
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                title: '서버 OSC 포트',
                hintText: '보통 12321',
                initialValue: serverOscPort.toString(),
                textInputType: TextInputType.number,
                onChanged: (inputText) {
                  serverOscPort = int.parse(inputText);
                },
              ),
            ),
            SizedBox(width: 24),
            Expanded(
              child: CustomTextFormField(
                title: '서버 MQTT 포트',
                hintText: '보통 12321',
                initialValue: serverMqttPort.toString(),
                textInputType: TextInputType.number,
                onChanged: (inputText) {
                  serverMqttPort = int.parse(inputText);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 20.0),
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                title: '서버 MQTT Id',
                initialValue: serverMqttId,
                onChanged: (inputText) {
                  serverMqttId = inputText;
                },
              ),
            ),
            SizedBox(width: 24),
            Expanded(
              child: CustomTextFormField(
                title: '서버 MQTT Password',
                initialValue: serverMqttPassword,
                onChanged: (inputText) {
                  serverMqttPassword = inputText;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
        title: '기본 정보 수정',
        widthRatio: 0.85,
        heightRatio: 0.55,
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: _BasicInfoEditor(key: ValueKey('OscEditor')),
                ),
              ),
              Container(
                constraints: BoxConstraints(maxWidth: 300),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: onSaveButtonPressed,
                      style: DIALOG_BTN_STYLE,
                      child: Text(
                        '저장',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onCancelButtonPressed,
                      style: DIALOG_BTN_STYLE,
                      child: Text(
                        '취소',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  void onSaveButtonPressed() async {
    String toastMsg = '';
    if (roomId != globalData.roomId ||
        roomName != globalData.roomName ||
        titleText != globalData.titleText ||
        wifiName != globalData.wifiName ||
        myOscPort != globalData.myOscPort ||
        serverIp != globalData.serverIp ||
        serverOscPort != globalData.serverOscPort ||
        serverMqttPort != globalData.serverMqttPort ||
        serverMqttId != globalData.serverMqttId ||
        serverMqttPassword != globalData.serverMqttPassword) {
      BasicInfoCompanion newBasicInfo = BasicInfoCompanion(
        roomId: Value(roomId),
        roomName: Value(roomName),
        titleText: Value(titleText),
        wifiName: Value(wifiName),
        myOscPort: Value(myOscPort),
        logoImage: Value(globalData.logoImage),
        serverIp: Value(serverIp),
        serverOscPort: Value(serverOscPort),
        serverMqttPort: Value(serverMqttPort),
        serverMqttId: Value(serverMqttId),
        serverMqttPassword: Value(serverMqttPassword),
      );

      await db.createBasicInfo(newBasicInfo);
      final newBasicInfoData = await db.getLatestBasicInfo();
      globalData.updateFromBasicInfoData(basicInfoData: newBasicInfoData!);
      toastMsg = '기본 정보 업데이트!';
      showCustomToast(toastMsg);

    }

    if (toastMsg == '') {
      toastMsg = '변경된 정보가 없습니다.';
      showCustomToast(toastMsg);
    } else {}

    Navigator.of(context).pop();
  }

  void onCancelButtonPressed() {
    Navigator.of(context).pop();
  }
}

class ButtonEditorDialog extends StatefulWidget {
  final String? buttonName;

  const ButtonEditorDialog({
    this.buttonName,
    super.key,
  });

  @override
  State<ButtonEditorDialog> createState() => _ButtonEditorDialogState();
}

class _ButtonEditorDialogState extends State<ButtonEditorDialog> {
  late final List<ButtonWithPage> bWpList;
  late final List<PageData> pageList;

  /// 버튼 정보
  late ButtonWithPage buttonWithPage;
  late ButtonData buttonData;
  late PageData pageData;

  late int buttonId;
  late String buttonName;
  late bool isUsingButton;
  late int page, row, column;
  late Command command;
  late String? queryString, message;

  bool isButtonExist = true;

  final db = GetIt.I<AppDatabase>();

  @override
  void initState() {
    // 장비상태 또는 버튼 정보 표출

    // 버튼 초기화
    if (widget.buttonName != null) {
      _initializeButtonData();
    }

    super.initState();
  }

  void _initializeButtonData() async {
    bWpList = await db.getButtonWithPage();
    pageList = await db.getPages();

    buttonWithPage = bWpList.firstWhere(
      (e) => e.button.buttonName == widget.buttonName,
      orElse: () => ButtonWithPage(
          button: ButtonData(
              buttonName: widget.buttonName ?? '할당된 버튼이 없습니다. 버튼을 생성합니다.',
              isUsingButton: true,
              page: 1,
              row: 0,
              column: 0,
              command: Command.press),
          page: bWpList.first.page),
    );

    buttonData = buttonWithPage.button;
    pageData = buttonWithPage.page;

    if (buttonData.id == null) {
      buttonId = bWpList.last.button.id! + 1;
    } else {
      buttonId = buttonData.id!;
    }

    setState(() {
      _checkButtonExistence();
    });

    buttonName = buttonData.buttonName;
    page = buttonData.page;
    row = buttonData.row;
    column = buttonData.column;
    command = buttonData.command;
    queryString = buttonData.queryString;
    message = buttonData.message;
    isUsingButton = buttonData.isUsingButton;
  }

  Future<void> _checkButtonExistence() async {
    isButtonExist = await db.doesButtonExist(buttonId);
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: widget.buttonName,
      titleActions: [
        // toggle
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: renderTitleToggle(),
        ),
      ],
      widthRatio: 0.5,
      heightRatio: 0.88,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: _OscEditor(key: ValueKey('OscEditor')),
              ),
            ),
            Container(
              constraints: BoxConstraints(maxWidth: 300),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: onSaveButtonPressed,
                    style: DIALOG_BTN_STYLE,
                    child: Text(
                      '저장',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onCancelButtonPressed,
                    style: DIALOG_BTN_STYLE,
                    child: Text(
                      '취소',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _OscEditor({Key? key}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomTextFormField(
                title: '동작명',
                initialValue: buttonName,
                isReadOnly: isButtonExist,
                onChanged: (inputText) {},
              ),
            ),
            SizedBox(width: 20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('동작형식',
                    style: TextStyle(
                        color: TEXT_COLOR,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 14.0),
                AnimatedToggleSwitch<bool>.dual(
                  current: isUsingButton,
                  first: true,
                  second: false,
                  spacing: 12.0,
                  height: 44.0,
                  style: const ToggleStyle(
                    borderColor: Colors.transparent,
                    indicatorColor: Colors.white,
                    backgroundColor: Colors.black,
                  ),
                  borderWidth: 6.0,
                  customStyleBuilder: (context, local, global) {
                    if (global.position <= 0.0) {
                      return ToggleStyle(backgroundColor: TOGGLE_BUTTON_COLOR);
                    }
                    return ToggleStyle(
                        backgroundGradient: LinearGradient(
                      colors: [TOGGLE_QUERY_COLOR, TOGGLE_BUTTON_COLOR],
                      stops: [
                        global.position -
                            (1 - 2 * max(0, global.position - 0.5)) * 0.7,
                        global.position +
                            max(0, 2 * (global.position - 0.5)) * 0.7,
                      ],
                    ));
                  },
                  onChanged: (b) => setState(() => isUsingButton = b),
                  textBuilder: (value) => value
                      ? const Center(
                          child: Text('버튼',
                              style: TextStyle(
                                  fontSize: 15, color: WHITE_TEXT_COLOR)))
                      : const Center(
                          child: Text('쿼리',
                              style: TextStyle(
                                  fontSize: 15, color: WHITE_TEXT_COLOR))),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomTextFormField(
                title: '행',
                initialValue: row.toString(),
                textInputType: TextInputType.number,
                onChanged: (inputText) {
                  row = int.parse(inputText);
                },
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: CustomTextFormField(
                title: '열',
                initialValue: column.toString(),
                textInputType: TextInputType.number,
                onChanged: (inputText) {
                  column = int.parse(inputText);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DropdownButton(
                value: page,
                dropdownColor: INPUT_BG_COLOR,
                items: pageList
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.id,
                        child: Text(e.pageName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    page = value;
                  });
                }),
            renderButtonCommandToggle(),
          ],
        ),
        SizedBox(height: 16.0),
        CustomTextFormField(
          title: '쿼리스트링',
          hintText: isButtonExist
              ? '버튼 대신 쿼리를 직접 입력할 때 사용합니다.'
              : '버튼 정보가 없습니다. 새로 생성합니다.',
          initialValue: queryString,
          onChanged: (inputText) {
            queryString = inputText;
          },
        ),
        SizedBox(height: 16.0),
        CustomTextFormField(
          title: '메세지',
          hintText:
              isButtonExist ? '일반적으로 입력하지 않습니다.' : '버튼 정보가 없습니다. 새로 생성합니다.',
          initialValue: message,
          onChanged: (inputText) {
            queryString = inputText;
          },
        ),
      ],
    );
  }

  Widget buildToggleButton<T>({
    required T currentValue,
    required List<T> values,
    required List<String> labels,
    required void Function(T) onChanged,
    Size indicatorSize = const Size.fromWidth(80),
  }) {
    return AnimatedToggleSwitch<T>.size(
      current: currentValue,
      style: ToggleStyle(
        borderColor: BORDER_COLOR,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 1.5),
          ),
        ],
        backgroundColor: DIALOG_TITLE_BG_COLOR,
        indicatorColor: TOGGLE_BUTTON_COLOR,
      ),
      values: values,
      iconOpacity: 1.0,
      selectedIconScale: 1.0,
      indicatorSize: indicatorSize,
      iconAnimationType: AnimationType.onHover,
      styleAnimationType: AnimationType.onHover,
      spacing: 2.0,
      customSeparatorBuilder: (context, local, global) {
        final opacity =
            ((global.position - local.position).abs() - 0.5).clamp(0.0, 1.0);
        return VerticalDivider(
            indent: 4.0,
            endIndent: 4.0,
            color: Colors.white38.withOpacity(opacity));
      },
      customIconBuilder: (context, local, global) {
        final text = labels[local.index];
        return Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Color.lerp(
                  TEXT_COLOR, WHITE_TEXT_COLOR, local.animationValue),
            ),
          ),
        );
      },
      borderWidth: 0.0,
      onChanged: onChanged,
    );
  }

  Widget renderButtonCommandToggle() {
    return buildToggleButton<Command>(
      currentValue: command,
      values: Command.values,
      labels: Command.values.map((e) => e.name).toList(),
      onChanged: (newCommand) => setState(() => command = newCommand),
    );
  }

  Widget renderTitleToggle() {
    List<bool> values = [false, true];
    List<String> texts = [
      'OSC',
    ];

    // if (widget.buttonName == null) {
    //   values = [true];
    //   texts = ['장비'];
    // } else if (fixedName == null) {
    //   values = [false];
    //   texts = ['OSC'];
    // }

    return buildToggleButton<bool>(
      currentValue: false,
      values: values,
      labels: texts,
      onChanged: (value) => setState(() {
        // isEditingEquip = value;
      }),
      indicatorSize: const Size.fromWidth(60),
    );
  }

  void onSaveButtonPressed() async {
    String toastMsg = '';
    if (widget.buttonName != null) {
      if (isUsingButton != buttonData.isUsingButton ||
          page != buttonData.page ||
          row != buttonData.row ||
          column != buttonData.column ||
          command != buttonData.command ||
          queryString != buttonData.queryString ||
          message != buttonData.message) {
        ButtonCompanion updatedButtonInfo = ButtonCompanion(
          id: Value(buttonId),
          buttonName: Value(buttonName),
          isUsingButton: Value(isUsingButton),
          page: Value(page),
          row: Value(row),
          column: Value(column),
          command: Value(command),
          queryString: Value(queryString),
          message: Value(message),
        );

        if (isButtonExist) {
          // ✅ 기존 버튼이 있으면 업데이트
          await db.updateButton(buttonId, updatedButtonInfo);
          showCustomToast('OSC 정보가 수정되었습니다.');
        } else {
          // ✅ 기존 버튼이 없으면 새로 생성
          await db.createButton(updatedButtonInfo);
          showCustomToast('OSC 정보가 생성되었습니다.');
        }
      }
    }

    if (toastMsg == '') {
      toastMsg = '변경된 정보가 없습니다.';
      showCustomToast(toastMsg);
    } else {}

    Navigator.of(context).pop();
  }

  void onCancelButtonPressed() {
    Navigator.of(context).pop();
  }
}
