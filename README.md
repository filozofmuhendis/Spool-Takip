# 🏭 AtölyeAkış - Endüstriyel Üretim Takip Sistemi

## 📱 Mobil Uygulama

Bu proje, endüstriyel üretim süreçlerini takip etmek için geliştirilmiş kapsamlı bir Flutter mobil uygulamasıdır. Supabase backend ile entegre çalışır ve gerçek zamanlı veri yönetimi sağlar.

## ✨ Özellikler

### 🔐 Güvenlik ve Kimlik Doğrulama
- **Supabase Auth** entegrasyonu
- **Rol tabanlı erişim kontrolü** (Admin, Süpervizör, İşçi, Görüntüleyici)
- **Güvenli oturum yönetimi**
- **Kullanıcı profil yönetimi**

### 📊 Proje Yönetimi
- **Proje oluşturma ve düzenleme**
- **Proje durumu takibi** (Aktif, Tamamlandı, Duraklatıldı, İptal)
- **Müşteri bilgileri**
- **Bütçe ve tarih yönetimi**
- **Proje kodu ve açıklama**

### 📋 İş Emri Yönetimi
- **İş emri oluşturma ve düzenleme**
- **İş emri numarası ve başlık**
- **Proje-spool ilişkilendirme**
- **Atanan kişi belirleme**
- **Durum takibi** (Bekliyor, Atandı, Devam Ediyor, Tamamlandı, İptal)
- **Öncelik seviyeleri** (Düşük, Orta, Yüksek, Acil)
- **Tahmini ve gerçek süre takibi**

### ⏱️ İş Takibi
- **İş başlatma/duraklatma/tamamlama**
- **Gerçek zamanlı iş durumu güncelleme**
- **İş süresi takibi**
- **İş takip kayıtları**
- **Notlar ve açıklamalar**

### 🔧 Spool Yönetimi
- **Spool oluşturma ve takibi**
- **Barkod entegrasyonu**
- **Spool detay bilgileri** (Malzeme, çap, ağırlık, EK, flans, manson, inç)
- **Çizim ve izometrik numara takibi**
- **Spool durumu yönetimi**

### 📦 Sevkiyat Yönetimi
- **Sevkiyat oluşturma ve takibi**
- **Hedef ve kargo firması bilgileri**
- **Takip numarası entegrasyonu**
- **Sevkiyat kalemleri yönetimi**
- **Teslim tarihi takibi**

### 📦 Stok Yönetimi
- **Malzeme kodu ve adı**
- **Kategori ve birim yönetimi**
- **Mevcut, minimum ve maksimum stok takibi**
- **Tedarikçi ve konum bilgileri**
- **Fiyat yönetimi**
- **Stok giriş/çıkış işlemleri**
- **İşlem geçmişi**

### ✅ Kalite Kontrol
- **Kalite kontrol kayıtları**
- **Denetçi ataması**
- **Sonuç takibi** (Geçti, Başarısız, Bekliyor)
- **Hata ve not kayıtları**
- **Denetim tarihi takibi**

### 📈 Üretim Planlama
- **Üretim planı oluşturma**
- **Başlangıç ve bitiş tarihleri**
- **Öncelik seviyeleri**
- **Ekip ataması**
- **Plan durumu takibi**

### 🔧 Ekipman Takibi
- **Ekipman kodu ve adı**
- **Kategori ve konum bilgileri**
- **Durum takibi** (Mevcut, Kullanımda, Bakım, Hizmet Dışı)
- **Bakım tarihleri**
- **Atanan kişi bilgileri**

### 📊 Raporlama
- **Performans raporları**
- **Tamamlanan iş sayıları**
- **Verimlilik oranları**
- **Dönemsel analizler**

### 🔔 Bildirimler
- **Gerçek zamanlı bildirimler**
- **Bildirim türleri** (Bilgi, Başarı, Uyarı, Hata)
- **Okundu/okunmadı durumu**
- **Bildirim geçmişi**

### 👥 Kullanıcı Yönetimi
- **Kullanıcı ekleme/düzenleme/silme**
- **Rol ataması**
- **Bildirim tercihleri**
- **Kullanıcı profilleri**

### 📝 İşlem Geçmişi
- **Tüm işlemlerin kaydı**
- **Değişiklik takibi**
- **Kullanıcı aktivite logları**
- **IP adresi ve tarayıcı bilgileri**

## 🛠️ Teknik Özellikler

### 📱 Mobil Uygulama
- **Flutter 3.x** ile geliştirilmiş
- **Responsive tasarım** (Telefon, tablet, masaüstü)
- **Material Design 3** arayüz
- **Cross-platform** (Android, iOS, Web)

### 🔧 Backend
- **Supabase** real-time database
- **PostgreSQL** veritabanı
- **Row Level Security (RLS)** politikaları
- **Real-time subscriptions**

### 🔐 Güvenlik
- **JWT token** tabanlı kimlik doğrulama
- **Rol tabanlı erişim kontrolü**
- **Veri şifreleme**
- **Güvenli API çağrıları**

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK 3.x
- Dart SDK 3.x
- Android Studio / VS Code
- Supabase hesabı

### Adım 1: Projeyi Klonlayın
```bash
git clone [repository-url]
cd Spool-Takip
```

### Adım 2: Bağımlılıkları Yükleyin
```bash
flutter pub get
```

### Adım 3: Supabase Kurulumu
1. [Supabase Dashboard](https://supabase.com/dashboard) adresine gidin
2. Yeni proje oluşturun
3. `supabase_setup_complete.sql` dosyasını SQL Editor'da çalıştırın
4. Proje URL'si ve anon key'i `lib/main.dart` dosyasında güncelleyin

### Adım 4: Uygulamayı Çalıştırın
```bash
flutter run
```

## 📋 Veritabanı Şeması

### Ana Tablolar
- **users** - Kullanıcı profilleri
- **projects** - Proje bilgileri
- **job_orders** - İş emirleri
- **job_order_tracking** - İş takip kayıtları
- **spools** - Spool bilgileri
- **spool_details** - Spool detayları
- **shipping** - Sevkiyat bilgileri
- **shipping_items** - Sevkiyat kalemleri
- **inventory** - Stok bilgileri
- **inventory_transactions** - Stok işlemleri
- **quality_control** - Kalite kontrol kayıtları
- **production_planning** - Üretim planları
- **equipment_tracking** - Ekipman takibi
- **notifications** - Bildirimler
- **transaction_history** - İşlem geçmişi

## 👥 Kullanıcı Rolleri

### 🔧 Admin
- Tüm modüllere tam erişim
- Kullanıcı yönetimi
- Sistem ayarları
- Raporlama

### 👨‍💼 Süpervizör
- Proje ve iş emri yönetimi
- Spool ve stok yönetimi
- Kalite kontrol
- Üretim planlama

### 👷 İşçi
- Kendisine atanan işleri görme
- İş başlatma/duraklatma/tamamlama
- Spool takibi
- Ekipman kullanımı

### 👁️ Görüntüleyici
- Sadece raporları görme
- İşlem geçmişi
- Bildirimler

## 📱 Ekran Görüntüleri

### Ana Menü
- Rol tabanlı menü öğeleri
- Responsive grid tasarım
- Hızlı erişim ikonları

### Proje Yönetimi
- Proje listesi ve detayları
- Durum ve öncelik göstergeleri
- Filtreleme ve arama

### İş Emri Yönetimi
- İş emri oluşturma formu
- Atama ve takip sistemi
- Durum güncellemeleri

### İş Takibi
- Gerçek zamanlı iş durumu
- Başlat/duraklat/tamarla butonları
- İş geçmişi

### Stok Yönetimi
- Stok listesi ve detayları
- Giriş/çıkış işlemleri
- Stok seviyesi uyarıları

## 🔄 Güncellemeler

### v2.0 (Güncel)
- ✅ Proje yönetimi eklendi
- ✅ İş emri yönetimi eklendi
- ✅ İş takibi sistemi eklendi
- ✅ Sevkiyat yönetimi eklendi
- ✅ Stok yönetimi eklendi
- ✅ Spool detay yönetimi eklendi
- ✅ Kapsamlı veritabanı şeması
- ✅ Rol tabanlı erişim kontrolü
- ✅ Responsive tasarım

### v1.0
- ✅ Temel spool takibi
- ✅ Kullanıcı yönetimi
- ✅ Bildirim sistemi
- ✅ Raporlama

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Commit yapın (`git commit -m 'Add some AmazingFeature'`)
4. Push yapın (`git push origin feature/AmazingFeature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakın.

## 📞 İletişim

- **Proje Sahibi**: [Adınız]
- **Email**: [email@example.com]
- **Proje Linki**: [https://github.com/username/Spool-Takip]

## 🙏 Teşekkürler

- Flutter ekibi
- Supabase ekibi
- Tüm katkıda bulunanlar

---

**Not**: Bu uygulama endüstriyel üretim süreçlerini optimize etmek ve verimliliği artırmak için tasarlanmıştır. Güvenlik ve veri bütünlüğü en üst düzeyde tutulmuştur.
