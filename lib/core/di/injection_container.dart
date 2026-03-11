import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:management_cabinet_medical_mobile/features/patient/data/repositories/patient_repository_impl.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/repositories/patient_repository.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/usecases/add_patient.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/usecases/delete_patient.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/usecases/fetch_patient_antecedents.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/usecases/get_antecedents_options.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/usecases/get_dropdown_options.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/usecases/get_patients.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/usecases/save_patient_antecedents.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/usecases/update_patient.dart';
import 'package:management_cabinet_medical_mobile/features/patient/presentation/providers/patient_provider.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/data/repositories/appointment_repository_impl.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/domain/usecases/add_appointment.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/domain/usecases/delete_appointment.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/domain/usecases/get_appointments.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/domain/usecases/update_appointment.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/presentation/providers/appointment_provider.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/data/repositories/waiting_room_repository_impl.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/domain/repositories/waiting_room_repository.dart';
import 'package:http/http.dart' as http;
import 'package:management_cabinet_medical_mobile/features/weather/domain/repositories/weather_repository.dart';
import 'package:management_cabinet_medical_mobile/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:management_cabinet_medical_mobile/features/weather/domain/usecases/get_weather_by_city.dart';
import 'package:management_cabinet_medical_mobile/features/weather/domain/usecases/get_weather_by_coordinates.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/domain/usecases/get_waiting_room_patients.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/domain/usecases/update_patient_status.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/domain/usecases/delete_waiting_room_patient.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/domain/usecases/add_waiting_room_patient.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/presentation/providers/waiting_room_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:management_cabinet_medical_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:management_cabinet_medical_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:management_cabinet_medical_mobile/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:management_cabinet_medical_mobile/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:management_cabinet_medical_mobile/features/auth/domain/usecases/sign_up.dart';
import 'package:management_cabinet_medical_mobile/features/auth/domain/usecases/delete_account.dart';
import 'package:management_cabinet_medical_mobile/features/auth/domain/usecases/forgot_password.dart';
import 'package:management_cabinet_medical_mobile/features/auth/domain/usecases/sign_out.dart';
import 'package:management_cabinet_medical_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:management_cabinet_medical_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:management_cabinet_medical_mobile/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:management_cabinet_medical_mobile/features/profile/domain/usecases/get_profile.dart';
import 'package:management_cabinet_medical_mobile/features/profile/domain/usecases/update_profile.dart';
import 'package:management_cabinet_medical_mobile/features/profile/domain/usecases/get_specialization_options.dart';
import 'package:management_cabinet_medical_mobile/features/profile/presentation/providers/profile_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => GoogleSignIn());

  // Features - Patient
  // Use cases
  sl.registerLazySingleton(() => GetPatients(sl()));
  sl.registerLazySingleton(() => AddPatient(sl()));
  sl.registerLazySingleton(() => UpdatePatient(sl()));
  sl.registerLazySingleton(() => DeletePatient(sl()));
  sl.registerLazySingleton(() => GetDropdownOptions(sl()));
  sl.registerLazySingleton(() => FetchPatientAntecedents(sl()));
  sl.registerLazySingleton(() => SavePatientAntecedents(sl()));
  sl.registerLazySingleton(() => GetAntecedentsOptions(sl()));

  // Repository
  sl.registerLazySingleton<PatientRepository>(
    () => PatientRepositoryImpl(firestore: sl(), auth: sl()),
  );

  // Features - Appointment
  // Use cases
  sl.registerLazySingleton(() => GetAppointments(sl()));
  sl.registerLazySingleton(() => AddAppointment(sl()));
  sl.registerLazySingleton(() => UpdateAppointment(sl()));
  sl.registerLazySingleton(() => DeleteAppointment(sl()));

  // Features - Weather
  sl.registerLazySingleton(() => GetWeatherByCity(sl()));
  sl.registerLazySingleton(() => GetWeatherByCoordinates(sl()));

  // Features - Waiting Room
  // Use cases
  sl.registerLazySingleton(() => GetWaitingRoomPatients(sl()));
  sl.registerLazySingleton(() => UpdatePatientStatus(sl()));
  sl.registerLazySingleton(() => DeleteWaitingRoomPatient(sl()));
  sl.registerLazySingleton(() => AddWaitingRoomPatient(sl()));

  // Features - Auth
  // Use cases
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => ForgotPassword(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => DeleteAccount(sl()));

  // Features - Profile
  // Use cases
  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => GetSpecializationOptions(sl()));

  // Repositories
  sl.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(firestore: sl(), auth: sl()),
  );

  sl.registerLazySingleton<WeatherRepository>(
    () => WeatherRepositoryImpl(client: sl()),
  );

  sl.registerLazySingleton<WaitingRoomRepository>(
    () => WaitingRoomRepositoryImpl(firestore: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
    ),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      firestore: sl(),
      storage: sl(),
    ),
  );

  // Providers
  sl.registerFactory(
    () => PatientProviderGlobal(
      getPatientsUseCase: sl(),
      addPatientUseCase: sl(),
      updatePatientUseCase: sl(),
      deletePatientUseCase: sl(),
      getDropdownOptionsUseCase: sl(),
      fetchPatientAntecedentsUseCase: sl(),
      savePatientAntecedentsUseCase: sl(),
      getAntecedentsOptionsUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => AppointmentProviderGlobal(
      getAppointmentsUseCase: sl(),
      addAppointmentUseCase: sl(),
      updateAppointmentUseCase: sl(),
      deleteAppointmentUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => WaitingRoomProviderGlobal(
      getWaitingRoomPatients: sl(),
      updatePatientStatus: sl(),
      deleteWaitingRoomPatient: sl(),
      addWaitingRoomPatient: sl(),
    ),
  );

  sl.registerFactory(
    () => AuthProviderGlobal(
      signInWithEmail: sl(),
      signInWithGoogle: sl(),
      signUp: sl(),
      forgotPassword: sl(),
      signOut: sl(),
      deleteAccount: sl(),
    ),
  );

  sl.registerFactory(
    () => ProfileProviderGlobal(
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
      getSpecializationOptionsUseCase: sl(),
      authProvider: sl(),
    ),
  );
}
