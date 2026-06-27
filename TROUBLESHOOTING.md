# Troubleshooting - Data Registrasi Tidak Tersimpan

## ⚠️ Penyebab Utama

### 1. **Web Mode (In-Memory Database)** ❌
Jika aplikasi dijalankan dengan `flutter run -d web-server`, database menggunakan in-memory storage:
- Data hanya tersimpan di RAM saat aplikasi running
- Data **hilang** setiap kali refresh/restart
- **Tidak cocok untuk production**

### 2. **UNIQUE Constraint Error** ❌
Email/NIM harus unik. Jika registrasi dengan email yang sama 2x, akan error UNIQUE constraint.

---

## ✅ Solusi

### Opsi 1: Testing dengan Android/iOS Device (Recommended)
```bash
# Untuk Android
flutter run -d android

# Untuk iOS
flutter run -d ios

# Untuk Linux/Windows
flutter run -d linux
flutter run -d windows
```
Data akan **persist** di device storage.

### Opsi 2: Testing di Web (Temporary Fix)
Jika harus pakai web, data hanya tersimpan selama session. 
- Jangan refresh halaman
- Jangan close tab
- Data hilang saat restart

---

## 🔍 Debug Steps

### 1. Cek Console untuk Error
Buka **Console** di DevTools (`Ctrl+Shift+J`):
- Cari pesan `❌ Registration error:`
- Lihat error type dan detail

### 2. Verifikasi Data Format
Pastikan form terisi dengan benar:
- **Nama**: tidak boleh kosong
- **NIM**: tidak boleh kosong (digunakan sebagai email)
- **WhatsApp**: tidak boleh kosong
- **Password**: minimal 8 karakter
- **Konfirmasi**: harus sama dengan password

### 3. Cek Database Logs
Aplikasi akan print ke console:
```
🔐 Starting registration for: user@email.com
📝 User data to insert: {nama: John, email: user, ...}
✅ Registration successful! User ID: 1
📊 Database users: [{id: 1, nama: John, ...}]
```

---

## 🚀 Untuk Production

### Migrate ke Hive atau Firebase
```dart
// Opsi 1: Gunakan Hive (local storage)
// Opsi 2: Gunakan Firebase Realtime Database
// Opsi 3: Gunakan REST API ke backend
```

---

## 📋 Checklist

- [ ] Jalankan app di device bukan web mode
- [ ] Pastikan form validation lulus (lihat console untuk error)
- [ ] Cek apakah email/NIM sudah di-register sebelumnya
- [ ] Lihat console output untuk debug logs
- [ ] Coba clear app data dan register ulang

---

## 💡 Tips

1. **Jangan refresh halaman** saat di web mode (data hilang)
2. **Gunakan different NIM** untuk setiap test registration
3. **Cek console logs** untuk error detail
4. **Switch ke device mode** untuk persistent storage

