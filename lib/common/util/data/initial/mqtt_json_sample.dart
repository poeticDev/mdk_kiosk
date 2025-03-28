/// Data Sample
///  관제실 -> 강의실 방향
/// 1. 웹앱 -> 관제서버 (WS)
const webAppToObserver = {
  "destination": "0-004-0101",
  "target": "wall_hub, class_hub",
  "data": {
    "timeRecord": "timeInKST",
    "mediaData": [
      {
        'id': "data.id",
        'title': "data.title",
        'type': "mediaTypeToString(data.type)",
        'url': "data.url",
        'fileName': "data.fileName",
        'from': "mediaFromToString(data.from)",
        'fit': "boxFitToString(data.fit)",
        'orderNum': "data.orderNum",
      },
      {
        'id': "data.id",
        'title': "data.title",
        'type': "mediaTypeToString(data.type)",
        'url': "data.url",
        'fileName': "data.fileName",
        'from': "mediaFromToString(data.from)",
        'fit': "boxFitToString(data.fit)",
        'orderNum': "data.orderNum",
      },
    ],
    "message": {
      "target": "wall_hub, class_hub",
      "until": "timeInKST",
      "content": "전달사항",
    },
  },
};

/// 2. 관제서버 -> 개별 강의실 서버
/// topic : observer/roomId
const observerToNodeRed = {
  "timeRecord": "timeInKST",
  "mediaData": [
    {
      'id': "data.id",
      'title': "data.title",
      'type': "mediaTypeToString(data.type)",
      'url': "data.url",
      'fileName': "data.fileName",
      'from': "mediaFromToString(data.from)",
      'fit': "boxFitToString(data.fit)",
      'orderNum': "data.orderNum",
    },
    {
      'id': "data.id",
      'title': "data.title",
      'type': "mediaTypeToString(data.type)",
      'url': "data.url",
      'fileName': "data.fileName",
      'from': "mediaFromToString(data.from)",
      'fit': "boxFitToString(data.fit)",
      'orderNum': "data.orderNum",
    },
  ],
  "message": {
    "target": "kiosk, classhub",
    "until": "TimeInUtc",
    "content": "전달사항",
  },
};

/// 3. 개별 강의실 서버 -> flutter(키오스크, 컨트롤러 앱)
/// 3.1. topic : node-mdk/{kiosk / tablet}/data
final nodeRedToFlutterData = {
  "timeRecord": DateTime.now().toString(),
  "mediaData": [
    {
      'id': "data.id",
      'title': "data.title",
      'type': "mediaTypeToString(data.type)",
      'url': "data.url",
      'fileName': "data.fileName",
      'from': "mediaFromToString(data.from)",
      'fit': "boxFitToString(data.fit)",
      'orderNum': "data.orderNum",
    },
    {
      'id': "data.id",
      'title': "data.title",
      'type': "mediaTypeToString(data.type)",
      'url': "data.url",
      'fileName': "data.fileName",
      'from': "mediaFromToString(data.from)",
      'fit': "boxFitToString(data.fit)",
      'orderNum': "data.orderNum",
    },
  ],
  "message": {
    "target": "kiosk, controller",
    "until": "TimeInUtc",
    "content": "전달사항",
  }
};

final jsonSample = {
  "timeRecord": "2025-03-06 20:47:33.258722",
  "mediaData": [
    {
      "id": "1",
      "title": "2025새해복",
      "type": "image",
      "url": "https://www.gnu.ac.kr/upload/main/na/bbs_5171/ntt_2264748/img_44ab9c58-a741-4b93-bd7b-ddeee17c0ac11736728581323.png",
      "from": "etc",
      "orderNum": "1"
    },
    {
      "id": "2",
      "title": "수강정정 안내",
      "type": "image",
      "url": "https://drive.google.com/file/d/1YKPA7ezjTsN1jIc79Zs0NM7Me-akXWVA/view?usp=sharing",
      "from": "gDrive",
      "orderNum": "2"
    }
  ],
  "message": {
    "target": "kiosk, controller",
    "until": "TimeInKSTf",
    "type" : "type",
    "content": "전달사항"
  }
};

/// 3.2. topic : node-mdk/states
const nodeRedToFlutterStates = {
  "lecturePC": {
    "desktop_gst0q4e_sessionstate": "Locked",
    "desktop_gst0q4e_lastactive": "2025-03-06T04:28:11+00:00"
  },
  "node_mdk": {"node_mdk": "Online"},
  "button1": {"action": "None"},
  "button2": {"action": "None", "battery": "100"}
};

///  강의실 -> 관제실 방향
/// 4. flutter(키오스크, 컨트롤러 앱) -> 개별 강의실 서버
/// 4.1. topic :
// const flutterToNodeRedData = {
//   "mediaData": [
//     {
//       'id': "data.id",
//       'title': "data.title",
//       'type': "mediaTypeToString(data.type)",
//       'url': "data.url",
//       'fileName': "data.fileName",
//       'from': "mediaFromToString(data.from)",
//       'fit': "boxFitToString(data.fit)",
//       'orderNum': "data.orderNum",
//     },
//     {
//       'id': "data.id",
//       'title': "data.title",
//       'type': "mediaTypeToString(data.type)",
//       'url': "data.url",
//       'fileName': "data.fileName",
//       'from': "mediaFromToString(data.from)",
//       'fit': "boxFitToString(data.fit)",
//       'orderNum': "data.orderNum",
//     },
//   ],
// };

/// 4.2. topic : node-mdk/state, classhub/state
const flutterToNodeRedState = {"state": "Online"};

/// 5. 개별 강의실 서버 -> 관제서버
/// 5.1. topic : node-red/states : 3.2와 동일
///
/// 5.2 topic : node-red/
