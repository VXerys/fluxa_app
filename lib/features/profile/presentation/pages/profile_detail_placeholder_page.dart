import 'package:flutter/material.dart';
import 'package:fluxa_app/core/icons/app_huge_icons.dart';
import 'package:fluxa_app/core/widgets/app_icon.dart';
import 'package:get/get.dart';
import 'package:fluxa_app/core/constants/app_colors.dart';
import 'package:fluxa_app/core/constants/app_spacing.dart';
import 'package:fluxa_app/core/constants/app_text_styles.dart';

// ==========================================
// 1. IMPOR DATA PAGE
// ==========================================
class ImporDataPage extends StatefulWidget {
  const ImporDataPage({super.key});

  @override
  State<ImporDataPage> createState() => _ImporDataPageState();
}

class _ImporDataPageState extends State<ImporDataPage> {
  bool _overwriteDuplicates = false;
  bool _skipDoubles = true;
  bool _createWallets = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Impor Data', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Upload Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: AppSpacing.s16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 2,
                  style: BorderStyle.none, // We'll simulate dashed with border styling or standard border
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  Get.snackbar(
                    'Pilih Berkas',
                    'Fitur pemilihan berkas CSV/Excel segera hadir pada update berikutnya!',
                    backgroundColor: AppColors.primary,
                    colorText: Colors.white,
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: const AppIcon(
                        AppHugeIcons.cloud_upload_outlined,
                        size: 30,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Text(
                      'Pilih Berkas CSV atau Excel',
                      style: AppTextStyles.roboto16w400.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      'Format yang didukung: .csv, .xls, .xlsx\nBatas ukuran file maksimal 10MB',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.roboto12w400.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            Text(
              'Opsi Impor',
              style: AppTextStyles.roboto14w400.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Ganti Kategori Duplikat'),
                    subtitle: const Text('Timpa kategori lokal jika terdapat nama yang sama'),
                    value: _overwriteDuplicates,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() {
                        _overwriteDuplicates = val;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Lewati Transaksi Ganda'),
                    subtitle: const Text('Jangan impor transaksi yang memiliki waktu & nominal persis'),
                    value: _skipDoubles,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() {
                        _skipDoubles = val;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Buat Dompet Otomatis'),
                    subtitle: const Text('Buat dompet baru jika nama dompet di file tidak terdaftar'),
                    value: _createWallets,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() {
                        _createWallets = val;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Get.snackbar(
                  'Info Impor',
                  'Fitur impor data CSV/Excel segera hadir pada update berikutnya!',
                  backgroundColor: AppColors.primary,
                  colorText: Colors.white,
                );
              },
              child: const Text('Mulai Impor Data', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. PERIODE PENCATATAN PAGE
// ==========================================
class PeriodePencatatanPage extends StatefulWidget {
  const PeriodePencatatanPage({super.key});

  @override
  State<PeriodePencatatanPage> createState() => _PeriodePencatatanPageState();
}

class _PeriodePencatatanPageState extends State<PeriodePencatatanPage> {
  int _cutoffDay = 1;
  String _viewMode = 'Bulanan';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Periode Pencatatan', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const AppIcon(AppHugeIcons.info_outline, color: AppColors.primary, size: 24),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Text(
                      'Tentukan awal siklus bulanan Anda (misal: disesuaikan dengan tanggal gajian) agar visualisasi grafik dan laporan keuangan Anda lebih akurat.',
                      style: AppTextStyles.roboto12w400.copyWith(color: AppColors.primaryLight),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            Text(
              'Awal Siklus Pencatatan',
              style: AppTextStyles.roboto14w400.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tanggal Mulai Bulanan', style: TextStyle(fontSize: 16)),
                      DropdownButton<int>(
                        value: _cutoffDay,
                        underline: const SizedBox(),
                        items: List.generate(31, (index) {
                          return DropdownMenuItem(
                            value: index + 1,
                            child: Text('Tanggal ${index + 1}'),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _cutoffDay = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: AppSpacing.s8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Mode Tampilan Laporan', style: TextStyle(fontSize: 16)),
                      Row(
                        children: ['Mingguan', 'Bulanan', 'Tahunan'].map((mode) {
                          final isSelected = _viewMode == mode;
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: ChoiceChip(
                              label: Text(mode),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _viewMode = mode;
                                  });
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Get.snackbar(
                  'Pengaturan Disimpan',
                  'Pengaturan periode pencatatan berhasil diperbarui secara lokal!',
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                );
              },
              child: const Text('Simpan Pengaturan Periode', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. KATEGORI PAGE
// ==========================================
class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _expenseCats = [
    {'name': 'Makan & Minum', 'icon': AppHugeIcons.fastfood, 'color': AppColors.categoryFood},
    {'name': 'Transportasi', 'icon': AppHugeIcons.directions_car, 'color': AppColors.categoryTransport},
    {'name': 'Belanja', 'icon': AppHugeIcons.shopping_bag, 'color': AppColors.categoryShopping},
    {'name': 'Tagihan', 'icon': AppHugeIcons.receipt, 'color': AppColors.categoryHousing},
    {'name': 'Hiburan', 'icon': AppHugeIcons.sports_esports, 'color': Colors.pink},
    {'name': 'Kesehatan', 'icon': AppHugeIcons.medical_services, 'color': Colors.red},
    {'name': 'Pendidikan', 'icon': AppHugeIcons.school, 'color': Colors.green},
    {'name': 'Lainnya', 'icon': AppHugeIcons.more_horiz, 'color': Colors.blueGrey},
  ];

  final List<Map<String, dynamic>> _incomeCats = [
    {'name': 'Gaji', 'icon': AppHugeIcons.work, 'color': Colors.green},
    {'name': 'Freelance', 'icon': AppHugeIcons.computer, 'color': Colors.teal},
    {'name': 'Bonus', 'icon': AppHugeIcons.monetization_on, 'color': Colors.amber},
    {'name': 'Hadiah', 'icon': AppHugeIcons.card_giftcard, 'color': Colors.purple},
    {'name': 'Jualan', 'icon': AppHugeIcons.storefront, 'color': Colors.orange},
    {'name': 'Lainnya', 'icon': AppHugeIcons.more_horiz, 'color': Colors.blueGrey},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Tambah Kategori Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Nama Kategori',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              const Text('Pilih Warna & Ikon (Preview)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.s8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(backgroundColor: AppColors.primary, child: const AppIcon(AppHugeIcons.star, color: Colors.white)),
                  CircleAvatar(backgroundColor: Colors.red, child: const AppIcon(AppHugeIcons.favorite, color: Colors.white)),
                  CircleAvatar(backgroundColor: Colors.amber, child: const AppIcon(AppHugeIcons.home, color: Colors.white)),
                  CircleAvatar(backgroundColor: Colors.green, child: const AppIcon(AppHugeIcons.shopping_cart, color: Colors.white)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Get.snackbar(
                  'Kategori Baru',
                  'Fitur kustomisasi kategori kustom segera hadir!',
                  backgroundColor: AppColors.primary,
                  colorText: Colors.white,
                );
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kategori', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Pengeluaran'),
            Tab(text: 'Pemasukan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList(_expenseCats),
          _buildCategoryList(_incomeCats),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        backgroundColor: AppColors.primary,
        child: const AppIcon(AppHugeIcons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryList(List<Map<String, dynamic>> categories) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.s16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.s12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: (cat['color'] as Color).withValues(alpha: 0.15),
              child: AppIcon(cat['icon'] as AppIconData, color: cat['color'] as Color),
            ),
            title: Text(cat['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const AppIcon(AppHugeIcons.edit_outlined, color: AppColors.textSecondary),
                  onPressed: () {
                    Get.snackbar(
                      'Ubah Kategori',
                      'Pengubahan kategori segera hadir!',
                      backgroundColor: AppColors.primary,
                      colorText: Colors.white,
                    );
                  },
                ),
                IconButton(
                  icon: const AppIcon(AppHugeIcons.delete_outline, color: AppColors.error),
                  onPressed: () {
                    Get.snackbar(
                      'Hapus Kategori',
                      'Hapus kategori dibatasi untuk kategori bawaan sistem.',
                      backgroundColor: AppColors.error,
                      colorText: Colors.white,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==========================================
// 4. PENGATURAN DOMPET PAGE
// ==========================================
class PengaturanDompetPage extends StatefulWidget {
  const PengaturanDompetPage({super.key});

  @override
  State<PengaturanDompetPage> createState() => _PengaturanDompetPageState();
}

class _PengaturanDompetPageState extends State<PengaturanDompetPage> {
  final List<Map<String, dynamic>> _wallets = [
    {
      'name': 'Dompet Tunai',
      'balance': 150000.0,
      'colors': [const Color(0xFF26A69A), const Color(0xFF66BB6A)],
      'show': true,
    },
    {
      'name': 'Rekening BCA',
      'balance': 4200000.0,
      'colors': [const Color(0xFF00C6FB), const Color(0xFF005BEA)],
      'show': true,
    },
    {
      'name': 'E-Wallet Gopay',
      'balance': 350000.0,
      'colors': [const Color(0xFFFA709A), const Color(0xFFFEE140)],
      'show': false,
    },
  ];

  void _showAddWalletSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Hubungkan Dompet/Rekening Baru',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.s16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Nama Dompet / Rekening',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              const TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Saldo Awal (Rp)',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Get.snackbar(
                    'Dompet Baru',
                    'Fitur multi-rekening/multi-dompet sedang dikembangkan!',
                    backgroundColor: AppColors.primary,
                    colorText: Colors.white,
                  );
                },
                child: const Text('Simpan Rekening', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pengaturan Dompet', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // List of existing wallets
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _wallets.length,
              itemBuilder: (context, index) {
                final w = _wallets[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.s16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: w['colors'] as List<Color>,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.s16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  w['name'] as String,
                                  style: AppTextStyles.roboto14w400.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s8),
                                Text(
                                  'Rp ${w['balance'].toInt()}',
                                  style: AppTextStyles.lora24w400.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Aktif',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                                  ),
                                  Switch(
                                    value: w['show'] as bool,
                                    activeColor: Colors.white,
                                    onChanged: (val) {
                                      setState(() {
                                        _wallets[index]['show'] = val;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.s8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _showAddWalletSheet,
              icon: const AppIcon(AppHugeIcons.add, color: AppColors.primary),
              label: const Text('Hubungkan Dompet Baru', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. TEMA PAGE
// ==========================================
class TemaPage extends StatefulWidget {
  const TemaPage({super.key});

  @override
  State<TemaPage> createState() => _TemaPageState();
}

class _TemaPageState extends State<TemaPage> {
  String _selectedTheme = 'Sistem';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tema Tampilan', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildThemeOption(
                    title: 'Mode Terang (Light Mode)',
                    icon: AppHugeIcons.light_mode_outlined,
                    value: 'Terang',
                  ),
                  const Divider(height: 1),
                  _buildThemeOption(
                    title: 'Mode Gelap (Dark Mode)',
                    icon: AppHugeIcons.dark_mode_outlined,
                    value: 'Gelap',
                  ),
                  const Divider(height: 1),
                  _buildThemeOption(
                    title: 'Ikuti Sistem Default',
                    icon: AppHugeIcons.settings_brightness_outlined,
                    value: 'Sistem',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            Text(
              'Catatan: Mode gelap penuh akan otomatis menyesuaikan palette warna visualisasi statistik pada update mendatang.',
              textAlign: TextAlign.center,
              style: AppTextStyles.roboto12w400.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required AppIconData icon,
    required String value,
  }) {
    final isSelected = _selectedTheme == value;
    return RadioListTile<String>(
      title: Row(
        children: [
          AppIcon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
          const SizedBox(width: AppSpacing.s16),
          Text(title, style: const TextStyle(fontSize: 16)),
        ],
      ),
      value: value,
      groupValue: _selectedTheme,
      activeColor: AppColors.primary,
      onChanged: (val) {
        if (val != null) {
          setState(() {
            _selectedTheme = val;
          });
          Get.snackbar(
            'Ubah Tema',
            'Mode Gelap (Dark Mode) premium sedang dalam tahap integrasi desain!',
            backgroundColor: AppColors.primary,
            colorText: Colors.white,
          );
        }
      },
    );
  }
}

// ==========================================
// 6. URUTAN MENU PAGE
// ==========================================
class UrutanMenuPage extends StatefulWidget {
  const UrutanMenuPage({super.key});

  @override
  State<UrutanMenuPage> createState() => _UrutanMenuPageState();
}

class _UrutanMenuPageState extends State<UrutanMenuPage> {
  final List<Map<String, dynamic>> _menuItems = [
    {'id': 'catat', 'name': 'Catat Transaksi', 'icon': AppHugeIcons.add_circle_outline, 'color': Colors.green},
    {'id': 'riwayat', 'name': 'Riwayat Keuangan', 'icon': AppHugeIcons.history, 'color': Colors.blue},
    {'id': 'profil', 'name': 'Profil Akun', 'icon': AppHugeIcons.person_outline, 'color': Colors.purple},
    {'id': 'lainnya', 'name': 'Fitur Lainnya', 'icon': AppHugeIcons.more_horiz, 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Urutan Menu Utama', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Text(
              'Tekan lama dan geser (drag & drop) untuk mengatur urutan menu tombol pintas di halaman beranda.',
              style: AppTextStyles.roboto14w400.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                return Card(
                  key: ValueKey(item['id']),
                  margin: const EdgeInsets.only(bottom: AppSpacing.s12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: (item['color'] as Color).withValues(alpha: 0.1),
                      child: AppIcon(item['icon'] as AppIconData, color: item['color'] as Color),
                    ),
                    title: Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const AppIcon(AppHugeIcons.drag_handle, color: AppColors.textSecondary),
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = _menuItems.removeAt(oldIndex);
                  _menuItems.insert(newIndex, item);
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Get.snackbar(
                  'Urutan Disimpan',
                  'Urutan menu kustom berhasil disimpan!',
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                );
              },
              child: const Text('Simpan Urutan Menu', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 7. URUTAN SECTION STATISTIK PAGE
// ==========================================
class UrutanSectionStatistikPage extends StatefulWidget {
  const UrutanSectionStatistikPage({super.key});

  @override
  State<UrutanSectionStatistikPage> createState() => _UrutanSectionStatistikPageState();
}

class _UrutanSectionStatistikPageState extends State<UrutanSectionStatistikPage> {
  final List<Map<String, dynamic>> _sections = [
    {'id': 'grafik_kategori', 'name': 'Grafik Pengeluaran Kategori', 'desc': 'Visualisasi diagram lingkaran pembagian pos pengeluaran.'},
    {'id': 'aliran_kas', 'name': 'Aliran Kas Bulanan', 'desc': 'Perbandingan pemasukan vs pengeluaran dalam diagram batang.'},
    {'id': 'tren_harian', 'name': 'Tren Pengeluaran Harian', 'desc': 'Grafik garis akumulasi pengeluaran Anda dari hari ke hari.'},
    {'id': 'rasio_tabungan', 'name': 'Rasio Tabungan', 'desc': 'Persentase sisa dana dari total pemasukan bersih.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Urutan Section Statistik', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Text(
              'Sesuaikan prioritas diagram laporan di tab Statistik. Geser section yang paling penting ke urutan teratas.',
              style: AppTextStyles.roboto14w400.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              itemCount: _sections.length,
              itemBuilder: (context, index) {
                final sec = _sections[index];
                return Card(
                  key: ValueKey(sec['id']),
                  margin: const EdgeInsets.only(bottom: AppSpacing.s12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  child: ListTile(
                    title: Text(sec['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(sec['desc'] as String, style: const TextStyle(fontSize: 12)),
                    trailing: const AppIcon(AppHugeIcons.drag_handle, color: AppColors.textSecondary),
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final sec = _sections.removeAt(oldIndex);
                  _sections.insert(newIndex, sec);
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Get.snackbar(
                  'Urutan Disimpan',
                  'Urutan tampilan statistik berhasil diatur!',
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                );
              },
              child: const Text('Simpan Urutan Statistik', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}





