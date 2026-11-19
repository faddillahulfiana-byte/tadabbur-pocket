-- ==============================================================================
-- SKRIP SETUP SUPABASE: TADABBUR POCKET
-- Jalankan skrip ini langsung di menu SQL Editor pada Supabase Dashboard Anda.
-- ==============================================================================

-- 1. TABEL: surahs (Data Surah Juz 30 & Materi Tadabbur)
CREATE TABLE IF NOT EXISTS public.surahs (
    id SERIAL PRIMARY KEY,
    surah_number INT UNIQUE NOT NULL,
    arabic_name TEXT NOT NULL,
    latin_name TEXT NOT NULL,
    meaning TEXT NOT NULL,
    total_verses INT NOT NULL,
    revelation_type TEXT NOT NULL, -- 'Makkiyah' atau 'Madaniyah'
    main_theme TEXT NOT NULL,
    tadabbur_points JSONB NOT NULL DEFAULT '[]'::jsonb,
    key_verse TEXT
);

-- 2. TABEL: quotes (Koleksi Ayat Al-Qur'an & Kata Motivasi Islami)
CREATE TABLE IF NOT EXISTS public.quotes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    quote_type TEXT NOT NULL CHECK (quote_type IN ('quran_verse', 'motivation')),
    content TEXT NOT NULL,
    arabic_text TEXT,
    source_ref TEXT NOT NULL, -- Contoh: "QS. Al-Insyirah: 5-6" atau "Imam Syafi'i"
    topic TEXT DEFAULT 'Motivasi & Pengingat',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. TABEL: user_profiles (Profil Pengguna & Preferensi Pengingat)
CREATE TABLE IF NOT EXISTS public.user_profiles (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT,
    reminder_time TIME DEFAULT '05:30:00',
    is_reminder_enabled BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. TABEL: murajaah_logs (Catatan Riwayat Sesi Murajaah Pengguna)
CREATE TABLE IF NOT EXISTS public.murajaah_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    surah_id INT NOT NULL REFERENCES public.surahs(id) ON DELETE CASCADE,
    verse_range TEXT NOT NULL DEFAULT '1 - Selesai',
    is_full_surah BOOLEAN DEFAULT TRUE,
    fluency_level TEXT NOT NULL CHECK (fluency_level IN ('lancar', 'perlu_diulang', 'belum_lancar')),
    notes TEXT,
    murajaah_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. TABEL: user_favorite_quotes (Daftar Quote Favorit Pengguna)
CREATE TABLE IF NOT EXISTS public.user_favorite_quotes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    quote_id UUID NOT NULL REFERENCES public.quotes(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, quote_id)
);

-- ==============================================================================
-- KEAMANAN: ROW LEVEL SECURITY (RLS)
-- ==============================================================================

ALTER TABLE public.surahs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.murajaah_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_favorite_quotes ENABLE ROW LEVEL SECURITY;

-- Policy surahs: Dapat dibaca oleh semua orang (guest & user login)
CREATE POLICY "Surahs can be viewed by anyone" 
    ON public.surahs FOR SELECT USING (true);

-- Policy quotes: Dapat dibaca oleh semua orang (guest & user login)
CREATE POLICY "Quotes can be viewed by anyone" 
    ON public.quotes FOR SELECT USING (true);

-- Policy user_profiles: Pengguna hanya dapat melihat dan memperbarui profil mereka sendiri
CREATE POLICY "Users can manage their own profile" 
    ON public.user_profiles FOR ALL USING (auth.uid() = user_id);

-- Policy murajaah_logs: Pengguna hanya dapat melakukan CRUD pada riwayat mereka sendiri
CREATE POLICY "Users can manage their own murajaah logs" 
    ON public.murajaah_logs FOR ALL USING (auth.uid() = user_id);

-- Policy user_favorite_quotes: Pengguna hanya dapat mengelola favorit mereka sendiri
CREATE POLICY "Users can manage their own favorites" 
    ON public.user_favorite_quotes FOR ALL USING (auth.uid() = user_id);

-- Trigger otomatis untuk membuat baris profile saat user baru signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (user_id, full_name)
    VALUES (new.id, COALESCE(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ==============================================================================
-- SEED DATA: 37 SURAH JUZ 30 (AN-NABA S.D. AN-NAS) DENGAN TADABBUR
-- ==============================================================================

INSERT INTO public.surahs (surah_number, arabic_name, latin_name, meaning, total_verses, revelation_type, main_theme, key_verse, tadabbur_points)
VALUES
(78, 'النبأ', 'An-Naba''', 'Berita Besar', 40, 'Makkiyah', 'Kepastian hari kiamat dan pertanggungjawaban atas segala nikmat alam semesta.', 'QS. An-Naba: 9 (Dan Kami jadikan tidurmu untuk istirahat)', 
 '["Semua fasilitas alam (bumi, gunung, tidur, siang-malam) diciptakan dengan tujuan penuh hikmah.", "Hari kebangkitan adalah kepastian yang tidak dapat dihindari.", "Renungi waktu istirahat dan nikmat tidur sebagai bentuk kasih sayang Allah."]'::jsonb),

(79, 'النازعات', 'An-Nazi''at', 'Malaikat Pencabut', 46, 'Makkiyah', 'Kedahsyatan pencabutan ruh manusia dan pelajaran dari keangkuhan Fir''aun.', 'QS. An-Nazi''at: 40-41 (Siapa yang takut pada keagungan Tuhannya dan menahan diri dari hawa nafsu, surga tempatnya)', 
 '["Kematian memisahkan ruh orang beriman dengan lembut dan ruh orang durhaka dengan keras.", "Kekuasaan sebesar Fir''aun runtuh seketika saat menentang kebenaran.", "Kunci surga adalah menundukkan hawa nafsu dan takut kepada Allah."]'::jsonb),

(80, 'عبس', '''Abasa', 'Ia Bermuka Masam', 42, 'Makkiyah', 'Teguran akhlak mulia dan keutamaan orang yang bersungguh-sungguh mencari ilmu.', 'QS. ''Abasa: 17 (Celakalah manusia! Alangkah kufurnya dia)', 
 '["Jangan menilai kemuliaan seseorang dari rupa, status sosial, atau kekayaannya.", "Orang yang tulus mencari kebaikan lebih berharga daripada pembesar yang berpaling sombong.", "Al-Qur''an adalah pengingat berharga yang suci dan dimuliakan."]'::jsonb),

(81, 'التكوير', 'At-Takwir', 'Menggulung', 29, 'Makkiyah', 'Perubahan dahsyat tata surya saat kiamat dan kebenaran wahyu Al-Qur''an.', 'QS. At-Takwir: 29 (Dan kamu tidak dapat menghendaki kecuali jika dikehendaki Allah)', 
 '["Segala keteraturan alam semesta yang kokoh saat ini berada di bawah kendali mutlak Allah.", "Kezaliman masa lalu sekecil apa pun akan dituntut keadilannya.", "Al-Qur''an disampaikan oleh malaikat yang mulia dan terpercaya."]'::jsonb),

(82, 'الانفطار', 'Al-Infitar', 'Terbelah', 19, 'Makkiyah', 'Teguran kepada manusia yang tertipu oleh kemurahan Allah sehingga melupakan ibadah.', 'QS. Al-Infitar: 6 (Wahai manusia, apakah yang telah memperdayakanmu berbuat durhaka terhadap Tuhanmu Yang Maha Pengasih)', 
 '["Kebaikan dan kemurahan Allah jangan sampai membuat kita lena dan melalaikan kewajiban.", "Ada malaikat pencatat yang senantiasa menyertai setiap gerak dan kata kita.", "Kelak tak ada yang bisa menolong selain amal saleh dan rahmat-Nya."]'::jsonb),

(83, 'المطففين', 'Al-Muthaffifin', 'Orang-Orang Curang', 36, 'Makkiyah', 'Integritas moral dalam muamalah dan kecaman keras bagi perilaku koruptif/curang.', 'QS. Al-Muthaffifin: 14 (Sekali-kali tidak! Bahkan apa yang mereka kerjakan itu telah menutupi hati mereka)', 
 '["Kecurangan sekecil menakar timbangan adalah dosa besar di sisi Allah.", "Dosa yang diulang-ulang akan menjadi noktah hitam yang mengunci kejernihan hati (ar-raan).", "Orang beriman akan menikmati balasan kemuliaan sejati di surga."]'::jsonb),

(84, 'الانشقاق', 'Al-Insyiqaq', 'Terbelah', 25, 'Makkiyah', 'Kepatuhan mutlak alam semesta kepada Allah dan proses penyerahan catatan amal.', 'QS. Al-Insyiqaq: 6 (Wahai manusia, sesungguhnya kamu telah bekerja keras menuju Tuhanmu, maka pasti kamu akan menemui-Nya)', 
 '["Manusia hakikatnya sedang dalam perjalanan melelahkan untuk kembali kepada Pencipta.", "Menerima catatan amal dari sebelah kanan adalah tanda kemenangan yang menenangkan.", "Langit dan bumi tunduk patuh pada ketetapan Allah, hendaknya manusia pun demikian."]'::jsonb),

(85, 'البروج', 'Al-Buruj', 'Gugusan Bintang', 22, 'Makkiyah', 'Keteguhan memegang iman menghadapi ujian berat dan jaminan pertolongan Allah.', 'QS. Al-Buruj: 16 (Maha Kuasa berbuat apa yang Dia kehendaki)', 
 '["Kisah Ashabul Ukhdud mengajarkan bahwa istiqomah iman lebih mahal dari nyawa.", "Kezaliman penguasa zalim tidak akan pernah luput dari perhitungan Allah.", "Al-Qur''an terjaga rapi di Lauhul Mahfuzh."]'::jsonb),

(86, 'الطارق', 'Ath-Thariq', 'Yang Datang di Malam Hari', 17, 'Makkiyah', 'Proses penciptaan manusia dari setetes air dan kebangkitan rahasia hati.', 'QS. Ath-Thariq: 9 (Pada hari dinampakkan segala rahasia)', 
 '["Merenungkan asal mula penciptaan dari air yang terpancar menumbuhkan rasa rendah hati.", "Dzat yang mampu menciptakan manusia dari ketiadaan pasti sanggup menghidupkannya kembali.", "Jagalah niat dan batin karena seluruh rahasia akan tersingkap."]'::jsonb),

(87, 'الأعلى', 'Al-A''la', 'Yang Paling Tinggi', 19, 'Makkiyah', 'Pensucian nama Allah, kemudahan dalam beramal, dan mengutamakan akhirat.', 'QS. Al-A''la: 14 (Sungguh beruntung orang yang menyucikan diri)', 
 '["Pujilah Allah yang telah menciptakan, menyempurnakan, dan memberi petunjuk.", "Allah menjanjikan kemudahan menuju jalan ketaatan (al-yusra).", "Kehidupan akhirat jauh lebih baik dan lebih kekal dibanding kilauan dunia."]'::jsonb),

(88, 'الغاشية', 'Al-Ghasyiyah', 'Hari Pembalasan', 26, 'Makkiyah', 'Perbandingan wajah penghuni neraka dan surga serta renungan atas unta, langit, dan bumi.', 'QS. Al-Ghasyiyah: 17 (Maka tidakkah mereka memperhatikan unta, bagaimana ia diciptakan?)', 
 '["Tanda-tanda kebesaran Allah nyata pada makhluk ciptaan di sekeliling kita.", "Tugas seorang dai dan hamba hanyalah memberi peringatan dengan santun, bukan memaksakan.", "Pilihlah amal yang membuat wajah berseri di hari penghabisan."]'::jsonb),

(89, 'الفجر', 'Al-Fajr', 'Fajar', 30, 'Makkiyah', 'Pemberian nikmat dan cobaan kekayaan serta ketenangan jiwa yang muthmainnah.', 'QS. Al-Fajr: 27-28 (Wahai jiwa yang tenang, kembalilah kepada Tuhanmu dengan hati yang ridha dan diridhai)', 
 '["Kekayaan bukan bukti Allah cinta, dan kekurangan rezeki bukan bukti Allah menghinakan.", "Ujian harta adalah bagaimana kita memuliakan anak yatim dan memberi makan kaum miskin.", "Rindukanlah derajat ''jiwa yang tenang'' yang disambut hangat oleh Allah."]'::jsonb),

(90, 'البلد', 'Al-Balad', 'Negeri', 20, 'Makkiyah', 'Hakikat hidup yang penuh perjuangan dan jalan terjal mendaki menuju kebaikan.', 'QS. Al-Balad: 4 (Sungguh Kami telah menciptakan manusia berada dalam susah payah)', 
 '["Hidup di dunia memang tempat berjuang dan lelah, istirahat sejatinya ada di surga.", "Jalan mendaki yang mulia (''aqabah) adalah membebaskan beban sesama dan saling menasihati dalam kesabaran serta kasih sayang."]'::jsonb),

(91, 'الشمس', 'Asy-Syams', 'Matahari', 15, 'Makkiyah', 'Sumpah alam semesta atas keberuntungan orang yang membersihkan jiwanya.', 'QS. Asy-Syams: 9 (Sungguh beruntung orang yang menyucikan jiwanya)', 
 '["Fokus terpenting hidup manusia adalah tazkiyatun nafs (membersihkan jiwa).", "Keserakahan dan menuruti hawa nafsu adalah jalan kehancuran sebagaimana kaum Tsamud.", "Pilihlah selalu bisikan ketakwaan di atas bisikan kefasikan."]'::jsonb),

(92, 'الليل', 'Al-Lail', 'Malam', 21, 'Makkiyah', 'Perbedaan karakter orang yang gemar memberi dan orang yang kikir merasa serba cukup.', 'QS. Al-Lail: 5-7 (Siapa yang memberi, bertakwa, dan membenarkan kebaikan, Kami mudahkan jalannya menuju kemudahan)', 
 '["Kedermawanan dan takwa melahirkan kelapangan hati dan kemudahan urusan.", "Sifat kikir dan merasa tidak butuh pertolongan Allah berujung pada kesempitan dan kesukaran hidup."]'::jsonb),

(93, 'الضحى', 'Adh-Dhuha', 'Waktu Dhuha', 11, 'Makkiyah', 'Penghiburan bagi hati yang sedih, bukti kasih sayang Allah, dan larangan bersikap kasar.', 'QS. Adh-Dhuha: 3 (Tuhanmu tidak meninggalkan engkau dan tidak pula membenci)', 
 '["Allah tidak pernah meninggalkan hamba-Nya yang sedang berjuang dalam kebaikan.", "Masa depan yang Allah siapkan kelak jauh lebih baik daripada masa lalu yang berat.", "Syukuri nikmat dengan berbagi dan berlemah-lembut kepada mereka yang membutuhkan."]'::jsonb),

(94, 'الشرح', 'Al-Insyirah', 'Kelapangan', 8, 'Makkiyah', 'Kelapangan dada, penghapusan beban jiwa, dan kepastian datangnya kemudahan setelah kesulitan.', 'QS. Al-Insyirah: 5-6 (Sesungguhnya bersama kesulitan ada kemudahan)', 
 '["Satu kesulitan tidak akan pernah mengalahkan dua kemudahan yang membersamainya.", "Kunci keluar dari beban hidup adalah terus bergerak produktif dan hanya berharap kepada Allah semata."]'::jsonb),

(95, 'التين', 'At-Tin', 'Buah Tin', 8, 'Makkiyah', 'Kemuliaan penciptaan manusia dalam bentuk terbaik dan bahaya jatuh ke tempat terendah.', 'QS. At-Tin: 4 (Sungguh Kami telah menciptakan manusia dalam bentuk yang sebaik-baiknya)', 
 '["Fisik dan potensi ruhani manusia diciptakan sangat mulia dan sempurna.", "Hanya iman dan amal saleh yang menjaga manusia agar tidak terperosok ke derajat yang paling hina."]'::jsonb),

(96, 'العلق', 'Al-''Alaq', 'Segumpal Darah', 19, 'Makkiyah', 'Perintah membaca dengan nama Allah, keutamaan ilmu, dan bahaya sifat melampaui batas.', 'QS. Al-''Alaq: 1 (Bacalah dengan menyebut nama Tuhanmu Yang Menciptakan)', 
 '["Ilmu harus diawali dan dibingkai dengan ketakwaan kepada Allah (Iqra'' bismi rabbika).", "Manusia kerap melampaui batas ketika merasa dirinya sudah serba kaya dan mandiri.", "Sujud adalah jalan terdekat seorang hamba kepada Rabbnya."]'::jsonb),

(97, 'القدر', 'Al-Qadr', 'Kemuliaan', 5, 'Makkiyah', 'Keagungan malam Lailatul Qadr dan diturunkannya permulaan wahyu Al-Qur''an.', 'QS. Al-Qadr: 3 (Malam kemuliaan itu lebih baik daripada seribu bulan)', 
 '["Al-Qur''an adalah sumber keberkahan terbesar bagi umat manusia.", "Satu malam yang diisi ketaatan tulus nilainya melampaui usia panjang puluhan tahun."]'::jsonb),

(98, 'البينة', 'Al-Bayyinah', 'Bukti Nyata', 8, 'Madaniyah', 'Kebutuhan manusia akan petunjuk nyata dan perintah memurnikan niat beribadah (ikhlas).', 'QS. Al-Bayyinah: 5 (Padahal mereka tidak diperintahkan kecuali agar menyembah Allah dengan ikhlas)', 
 '["Ikhlas adalah ruh dari setiap ibadah yang diterima.", "Menjaga salat dan menunaikan zakat adalah tonggak kelurusan agama.", "Orang beriman dan beramal saleh adalah sebaik-baik makhluk di bumi."]'::jsonb),

(99, 'الزلزلة', 'Az-Zalzalah', 'Goncangan', 8, 'Madaniyah', 'Guncangan dahsyat kiamat dan hisab kebaikan atau keburukan hingga sebesar zarrah.', 'QS. Az-Zalzalah: 7 (Maka barangsiapa mengerjakan kebaikan seberat zarrah, niscaya dia akan melihatnya)', 
 '["Bumi akan menjadi saksi atas setiap jejak perbuatan manusia di atasnya.", "Jangan pernah meremehkan amal kebaikan sekecil apa pun, dan jangan sepelekan dosa sekecil apa pun."]'::jsonb),

(100, 'العاديات', 'Al-''Adiyat', 'Kuda Perang yang Berlari Kencang', 11, 'Makkiyah', 'Pengorbanan kuda yang setia dan sindiran bagi manusia yang ingkar serta cinta berlebihan pada harta.', 'QS. Al-''Adiyat: 6 (Sungguh manusia itu sangat ingkar kepada Tuhannya)', 
 '["Kuda setia mempertaruhkan nyawa demi tuannya; sudahkah kita setia taat kepada Allah yang memberi nafas?", "Cinta harta yang berlebihan dapat membutakan nurani dari kepedulian akhirat."]'::jsonb),

(101, 'القارعة', 'Al-Qari''ah', 'Hari Kiamat', 11, 'Makkiyah', 'Goncangan kiamat yang memporak-porandakan dan penimbangan beratnya timbangan amal.', 'QS. Al-Qari''ah: 6-7 (Maka barangsiapa berat timbangan kebaikannya, dia berada dalam kehidupan yang memuaskan)', 
 '["Di hari kiamat manusia diibaratkan laron beterbangan dan gunung seperti bulu yang dihambur-hamburkan.", "Fokus hidup adalah memperberat timbangan amal kebajikan sebelum waktu terhenti."]'::jsonb),

(102, 'التكاثر', 'At-Takatsur', 'Bermegah-megahan', 8, 'Makkiyah', 'Bahaya perlombaan menumpuk materi hingga masuk kubur dan pertanggungjawaban atas setiap nikmat.', 'QS. At-Takatsur: 8 (Kemudian kamu pasti akan ditanya pada hari itu tentang kenikmatan)', 
 '["Keserakahan mengejar gengsi dunia seringkali baru tersadar saat jasad masuk liang lahad.", "Setiap sendok makanan, teguk air, dan detik kenyamanan akan dimintai pertanggungjawaban."]'::jsonb),

(103, 'العصر', 'Al-''Ashr', 'Masa / Waktu', 3, 'Makkiyah', 'Hakikat waktu dan formula penyelamat manusia dari kerugian mutlak.', 'QS. Al-''Ashr: 2-3 (Sungguh manusia berada dalam kerugian, kecuali orang-orang yang beriman, beramal saleh, saling menasihati dalam kebenaran dan kesabaran)', 
 '["Waktu terus mengikis umur kita tanpa bisa diulang kembali.", "Empat pilar keselamatan hidup: Iman yang kokoh, amal saleh nyata, dakwah kebenaran, dan ketabahan dalam kesabaran."]'::jsonb),

(104, 'الهمزة', 'Al-Humazah', 'Pengumpat', 9, 'Makkiyah', 'Kecaman bagi orang yang suka mencela, menggunjing, dan mengira hartanya menjadikannya kekal.', 'QS. Al-Humazah: 1 (Celakalah setiap pengumpat lagi pencela)', 
 '["Lidah yang suka mencela dan mencibir sesama adalah jalan tercepat mengundang murka Allah.", "Harta sebanyak apa pun tidak akan pernah mampu memperpanjang batas umur manusia."]'::jsonb),

(105, 'الفيل', 'Al-Fil', 'Gajah', 5, 'Makkiyah', 'Kisah kehancuran pasukan bergajah Abrahah yang ingin menghancurkan Ka''bah.', 'QS. Al-Fil: 1 (Tidakkah engkau perhatikan bagaimana Tuhanmu telah bertindak terhadap pasukan bergajah?)', 
 '["Kekuatan militer dan materi terbesar akan hancur lebur di hadapan tentara kecil utusan Allah.", "Allah senantiasa menjaga rumah suci-Nya dan orang-orang yang ikhlas membela agama-Nya."]'::jsonb),

(106, 'قريش', 'Quraisy', 'Suku Quraisy', 4, 'Makkiyah', 'Dua pilar kesejahteraan hidup: kemakmuran pangan dan rasa aman dari ketakutan.', 'QS. Quraisy: 3-4 (Maka hendaklah mereka menyembah Tuhan pemilik rumah ini yang telah memberi makan untuk menghilangkan lapar dan mengamankan mereka dari ketakutan)', 
 '["Kecukupan rezeki dan rasa aman di suatu negeri adalah nikmat agung yang wajib disyukuri dengan beribadah.", "Kenyamanan hidup seharusnya mendekatkan diri kepada Sang Pemberi Aman."]'::jsonb),

(107, 'الماعون', 'Al-Ma''un', 'Barang-Barang Berguna', 7, 'Makkiyah', 'Ciri pendusta agama: menghardik anak yatim, enggan menolong, dan salat yang riya/lalai.', 'QS. Al-Ma''un: 4-5 (Maka celakalah orang-orang yang salat, yaitu yang lalai dari salatnya)', 
 '["Ibadah ritual (salat) tidak ada artinya jika tidak membuahkan kepedulian sosial pada orang miskin dan yatim.", "Menolak meminjamkan barang sepele yang dibutuhkan tetangga termasuk tanda kekerasan hati."]'::jsonb),

(108, 'الكوثر', 'Al-Kautsar', 'Nikmat yang Berlimpah', 3, 'Makkiyah', 'Kelimpahan karunia bagi Rasulullah saw dan perintah berkurban serta bersyukur.', 'QS. Al-Kautsar: 1-2 (Sungguh Kami telah memberimu nikmat yang banyak, maka salatlah karena Tuhanmu dan berkurbanlah)', 
 '["Karunia Allah kepada orang beriman tiada terhitung; balaslah dengan salat yang khusyuk dan pengorbanan yang tulus.", "Kebaikan hakiki akan terus dikenang, sementara kebencian musuh-musuh kebenaran akan terputus."]'::jsonb),

(109, 'الكافرون', 'Al-Kafirun', 'Orang-Orang Kafir', 6, 'Makkiyah', 'Ketegasan akidah dan prinsip toleransi tanpa kompromi dalam peribadatan.', 'QS. Al-Kafirun: 6 (Untukmu agamamu, dan untukkulah agamaku)', 
 '["Akidah dan ibadah tidak boleh dicampuradukkan dengan dalih kompromi.", "Toleransi sejati adalah menghormati hak berkeyakinan orang lain sambil teguh memegang keyakinan sendiri."]'::jsonb),

(110, 'النصر', 'An-Nashr', 'Pertolongan', 3, 'Madaniyah', 'Kemenangan dakwah dan adab menyikapi keberhasilan dengan bertasbih dan memohon ampun.', 'QS. An-Nashr: 1-2 (Apabila telah datang pertolongan Allah dan kemenangan)', 
 '["Ketika sebuah perjuangan meraih puncak keberhasilan, hindari kebanggaan semu atau kesombongan diri.", "Sambutlah kemenangan dengan semakin banyak beristigfar dan memuji keagungan Allah."]'::jsonb),

(111, 'Al-Lahab', 'Al-Lahab', 'Gejolak Api', 5, 'Makkiyah', 'Kesesatan Abu Lahab dan istrinya yang menentang dakwah serta nasib harta yang sia-sia.', 'QS. Al-Lahab: 2 (Tidaklah berguna baginya hartanya dan apa yang dia usahakan)', 
 '["Kekerabatan dengan orang saleh tidak berguna bila diri sendiri menolak kebenaran.", "Harta dan kedudukan dunia tidak dapat membentengi manusia dari azab Allah."]'::jsonb),

(112, 'الإخلاص', 'Al-Ikhlas', 'Kemurnian Keesaan Allah', 4, 'Makkiyah', 'Pilar tauhid yang murni: Allah Maha Esa, tempat bergantung segala makhluk, tiada beranak dan tiada tara.', 'QS. Al-Ikhlas: 2 (Allah tempat bergantung segala sesuatu)', 
 '["Hanya kepada Allah tempat seluruh makhluk menggantungkan harapan dan kebutuhan hidup.", "Allah Maha Sempurna dan suci dari segala sifat keterbatasan makhluk."]'::jsonb),

(113, 'الفلق', 'Al-Falaq', 'Waktu Subuh', 5, 'Makkiyah', 'Perlindungan diri kepada Allah dari kejahatan malam, sihir, dan kedengkian manusia.', 'QS. Al-Falaq: 5 (Dan dari kejahatan orang yang dengki apabila dia dengki)', 
 '["Kejahatan di dunia nyata dan gaib ada; mintalah perlindungan kepada Pemilik Fajar.", "Penyakit hasad/dengki sangat berbahaya bagi jiwa; bentengi diri dengan zikir perlindungan ini."]'::jsonb),

(114, 'الناس', 'An-Nas', 'Umat Manusia', 6, 'Makkiyah', 'Perlindungan diri dari bisikan tersembunyi setan yang menggoda hati manusia.', 'QS. An-Nas: 4 (Dari kejahatan bisikan setan yang bersembunyi)', 
 '["Bisikan was-was setan menyusup halus ke dalam dada manusia.", "Menjadikan Allah sebagai Raja dan Sesembahan sejati adalah benteng terkuat melawan godaan nafsu dan setan."]'::jsonb)
ON CONFLICT (surah_number) DO NOTHING;

-- ==============================================================================
-- SEED DATA: 25-30 QUOTE ISLAMI (AYAT AL-QUR'AN & KATA MOTIVASI ISLAMI)
-- ==============================================================================

INSERT INTO public.quotes (quote_type, content, arabic_text, source_ref, topic)
VALUES
-- Kategori: Ayat Al-Qur'an
('quran_verse', 'Maka sesungguhnya bersama kesulitan ada kemudahan, sesungguhnya bersama kesulitan ada kemudahan.', 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا إِنَّ مَعَ الْعُسْرِ يُسْرًا', 'QS. Al-Insyirah: 5-6', 'Harapan & Keteguhan'),
('quran_verse', 'Dan Tuhanmu berfirman: Berdoalah kepada-Ku, niscaya akan Kuperkenankan bagimu.', 'وَقَالَ رَبُّكُمُ ادْعُونِي أَسْتَجِبْ لَكُمْ', 'QS. Ghafir: 60', 'Doa & Kedekatan'),
('quran_verse', 'Ingatlah, hanya dengan mengingat Allah hati menjadi tenteram.', 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ', 'QS. Ar-Ra''d: 28', 'Ketenangan Jiwa'),
('quran_verse', 'Dan barangsiapa bertakwa kepada Allah, niscaya Dia menjadikan kemudahan baginya dalam urusannya.', 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مِنْ أَمْرِهِ يُسْرًا', 'QS. At-Talaq: 4', 'Takwa & Kemudahan'),
('quran_verse', 'Allah tidak membebani seseorang melainkan sesuai dengan kesanggupannya.', 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا', 'QS. Al-Baqarah: 286', 'Kekuatan Diri'),
('quran_verse', 'Dan Kami telah memudahkan Al-Qur''an untuk peringatan, maka adakah orang yang mau mengambil pelajaran?', 'وَلَقَدْ يَسَّرْنَا الْقُرْآنَ لِلذِّكْرِ فَهَلْ مِن مُّدَّكِرٍ', 'QS. Al-Qamar: 17', 'Al-Qur''an & Hafalan'),
('quran_verse', 'Dan bersabarlah kamu, sesungguhnya janji Allah adalah benar.', 'فَاصْبِرْ إِنَّ وَعْدَ اللَّهِ حَقٌّ', 'QS. Ar-Rum: 60', 'Kesabaran'),
('quran_verse', 'Dan Dia mendapatimu sebagai seorang yang bingung, lalu Dia memberikan petunjuk.', 'وَوَجَدَكَ ضَالًّا فَهَدَىٰ', 'QS. Adh-Dhuha: 7', 'Petunjuk & Rahmat'),
('quran_verse', 'Dan barangsiapa bertawakal kepada Allah, niscaya Allah akan mencukupkan keperluannya.', 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ', 'QS. At-Talaq: 3', 'Tawakal'),
('quran_verse', 'Wahai jiwa yang tenang, kembalilah kepada Tuhanmu dengan hati yang ridha lagi diridhai-Nya.', 'يَا أَيَّتُهَا النَّفْسُ الْمُطْمَئِنَّةُ ارْجِعِي إِلَىٰ رَبِّكِ رَاضِيَةً مَّرْضِيَّةً', 'QS. Al-Fajr: 27-28', 'Jiwa & Akhirat'),
('quran_verse', 'Tidakkah engkau tahu bahwa sesungguhnya Allah mengetahui apa yang ada di langit dan di bumi?', 'أَلَمْ تَعْلَمْ أَنَّ اللَّهَ يَعْلَمُ مَا فِي السَّمَاءِ وَالْأَرْضِ', 'QS. Al-Hajj: 70', 'Pengawasan Allah'),
('quran_verse', 'Maka barangsiapa mengerjakan kebaikan seberat zarrah, niscaya dia akan melihat balasannya.', 'فَمَن يَعْمَلْ مِثْقَالَ ذَرَّةٍ خَيْرًا يَرَهُ', 'QS. Az-Zalzalah: 7', 'Amal Kebaikan'),
('quran_verse', 'Katakanlah: Wahai hamba-hamba-Ku yang melampaui batas terhadap diri mereka sendiri, janganlah berputus asa dari rahmat Allah.', 'قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ', 'QS. Az-Zumar: 53', 'Rahmat & Ampunan'),
('quran_verse', 'Dan rendahkanlah dirimu terhadap mereka berdua dengan penuh kesayangan dan ucapkanlah: Wahai Tuhanku, sayangilah keduanya sebagaimana mereka mendidikku waktu kecil.', 'وَاخْفِضْ لَهُمَا جَنَاحَ الذُّلِّ مِنَ الرَّحْمَةِ وَقُل رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا', 'QS. Al-Isra: 24', 'Berbakti Orang Tua'),
('quran_verse', 'Dan orang-orang yang berjihad untuk mencari keridhaan Kami, benar-benar akan Kami tunjukkan kepada mereka jalan-jalan Kami.', 'وَالَّذِينَ جَاهَدُوا فِينَا لَنَهْدِيَنَّهُمْ سُبُلَنَا', 'QS. Al-Ankabut: 69', 'Keseriusan Belajar'),

-- Kategori: Motivasi Islami
('motivation', 'Sebaik-baik kalian adalah orang yang belajar Al-Qur''an dan mengajarkannya kepada sesama.', NULL, 'HR. Bukhari No. 5027', 'Kemuliaan Al-Qur''an'),
('motivation', 'Hafalan Al-Qur''an itu bagaikan unta yang diikat. Jika engkau rajin merawat dan mengikatnya (murajaah), ia akan tetap ada padamu.', NULL, 'HR. Bukhari & Muslim', 'Konsistensi Murajaah'),
('motivation', 'Barangsiapa menempuh suatu jalan untuk menuntut ilmu, maka Allah akan memudahkan baginya jalan menuju surga.', NULL, 'HR. Muslim No. 2699', 'Semangat Menuntut Ilmu'),
('motivation', 'Jadikanlah setiap hela nafasmu bernilai ibadah, dan setiap kesulitan dalam menghafal sebagai penggugur dosa-dosamu.', NULL, 'Nasihat Ulama Salaf', 'Motivasi Diri'),
('motivation', 'Bukan hafalan yang lambat yang perlu engkau khawatirkan, melainkan hati yang enggan mendekat dan kembali kepada Al-Qur''an.', NULL, 'Mutiara Hikmah Qur''ani', 'Keikhlasan'),
('motivation', 'Keluarga Allah di bumi adalah ahlul Qur''an; mereka adalah orang-orang istimewa dan terpilih di sisi-Nya.', NULL, 'HR. Ibnu Majah No. 215', 'Kemuliaan Ahlul Qur''an'),
('motivation', 'Jika engkau lelah dalam mengulang hafalan, ingatlah bahwa rasa lelah itu akan sirna, sedangkan pahala dan kemuliaan ayatnya akan kekal selamanya.', NULL, 'Imam Asy-Syafi''i', 'Kesabaran & Ketabahan'),
('motivation', 'Jangan tunggu ada waktu luang untuk membaca dan tadabbur Al-Qur''an, tetapi luangkanlah waktumu secara khusus untuknya.', NULL, 'Mutiara Nasihat', 'Manajemen Waktu'),
('motivation', 'Hati itu seperti cermin. Ayat-ayat Al-Qur''an dan tadabbur adalah pembersih debunya agar memantulkan cahaya kebaikan.', NULL, 'Ibnul Qayyim Al-Jauziyyah', 'Tazkiyatun Nafs'),
('motivation', 'Satu ayat yang dipahami maknanya dan diresapi dalam shalat, jauh lebih menyentuh jiwa daripada membaca berlembar-lembar tanpa renungan.', NULL, 'Hasan Al-Bashri', 'Tadabbur & Khusyuk'),
('motivation', 'Sesungguhnya pertolongan Allah itu datang sebanding dengan kadar niat dan ketulusan hamba-Nya.', NULL, 'Mutiara Hikmah', 'Ketulusan Niat'),
('motivation', 'Di akhirat kelak, akan dikatakan kepada penghafal Al-Qur''an: Bacalah, naiklah, dan tartilkanlah sebagaimana engkau membaca tartil di dunia!', NULL, 'HR. Tirmidzi & Abu Dawud', 'Derajat Penghafal');
