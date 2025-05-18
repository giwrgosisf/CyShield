import '../../models/child_model.dart';
import '../../models/message_model.dart';

class ReportsRepository {
  Future<List<ChildModel>> getFlaggedReports() async {
    return [
      ChildModel(
        name: "Μαρία",
        avatar: "assets/images/Marie.png",
        safePercent: 0.7,
        moderatePercent: 0.2,
        toxicPercent: 0.1,
        flaggedMessages: [
          MessageModel(
            senderName: "Άγνωστος",
            text: "Όλοι στο σχολείο σε μισούν!",
            probability: 0.60,
            time: "11:22 ΠΜ",
          ),
          MessageModel(
            senderName: "Σοφία",
            text: "Τουλάχιστον έχω καλύτερα ρούχα από εσένα!",
            probability: 0.97,
            time: "10:21 ΠΜ",
          ),
        ],
      ),
      ChildModel(
        name: "Μάριος",
        avatar: "assets/images/austin.png",
        safePercent: 0.7,
        moderatePercent: 0.1,
        toxicPercent: 0.3,
        flaggedMessages: [
          MessageModel(
            senderName: "Ανδρέας",
            text: "Έχεις δει ποτέ τον εαυτό σου στον καθρέφτη;",
            probability: 0.90,
            time: "12:25 ΠΜ",
          ),
        ],
      ),
    ];
  }
}
