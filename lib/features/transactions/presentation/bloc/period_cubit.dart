import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/date_utils.dart';

class PeriodCubit extends Cubit<TransactionPeriod> {
  PeriodCubit() : super(TransactionPeriod.month);
}
