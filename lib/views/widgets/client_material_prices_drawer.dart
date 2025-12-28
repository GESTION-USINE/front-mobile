import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/entities/material_price.dart';
import '../../viewmodels/material_viewmodel.dart';
import './generic_data_table.dart';

/// Widget réutilisable pour gérer les prix spéciaux des matériaux pour un client
/// Affiche une liste de matériaux avec leurs prix par défaut et prix spéciaux (si existants)
class ClientMaterialPricesDrawer extends StatefulWidget {
  /// Client pour lequel afficher/modifier les prix
  final dynamic client;

  /// Callback appelé quand on veut fermer le drawer
  final VoidCallback onClose;

  /// Callback optionnel appelé après enregistrement réussi
  final VoidCallback? onSaved;

  const ClientMaterialPricesDrawer({
    super.key,
    required this.client,
    required this.onClose,
    this.onSaved,
  });

  @override
  State<ClientMaterialPricesDrawer> createState() =>
      _ClientMaterialPricesDrawerState();
}

class _ClientMaterialPricesDrawerState
    extends State<ClientMaterialPricesDrawer> {
  late final Map<int, TextEditingController> _priceControllers = {};
  bool _isSaving = false;

  @override
  void dispose() {
    for (final c in _priceControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _initControllers(List<MaterialPriceItem> items) {
    for (final item in items) {
      if (!_priceControllers.containsKey(item.materialId)) {
        final text =
            item.customPricePerTon != null ? item.customPricePerTon!.toString() : '';
        _priceControllers[item.materialId] = TextEditingController(text: text);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<MaterialViewModel>(
      builder: (context, mvm, child) {
        final items = mvm.materialPrices;
        _initControllers(items);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre et description
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prix matériaux - ${widget.client?.name ?? 'Client'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.industrialText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Modifiez les prix spéciaux pour ce client.',
                    style: const TextStyle(fontSize: 11, color: AppColors.grey600),
                  ),
                ],
              ),
            ),

            // Tableau scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: items.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : GenericDataTable<MaterialPriceItem>(
                        items: items,
                        columns: [
                          DataTableColumn<MaterialPriceItem>(
                            label: 'Matériau',
                            value: (item) =>  '${item.materialName}'
                          ),
                          DataTableColumn<MaterialPriceItem>(
                            label: 'Prix défaut',
                            value: (item) =>
                                '${item.defaultPricePerTon.toStringAsFixed(2)} DA',
                          ),
                          DataTableColumn<MaterialPriceItem>(
                            label: 'Prix spécial',
                            value: (item) {
                              final controller =
                                  _priceControllers[item.materialId]!;
                              return SizedBox(
                                width: 100,
                                child: TextFormField(
                                  controller: controller,
                                  keyboardType:
                                       TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  style:  TextStyle(
                                    fontSize: 12,
                                    color: AppColors.black,
                                  ),
                                  decoration:  InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    fillColor: AppColors.white,
                                    suffixIconConstraints:  BoxConstraints(
                                      minWidth: 24,
                                      minHeight: 24,
                                    ),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    hintText: 'Optionnel',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: AppColors.grey300,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: AppColors.grey300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: AppColors.industrialPrimary,
                                      ),
                                    ),
                                    suffixIcon: controller.text.isNotEmpty
                                        ? const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.check_circle,
                                              color: AppColors
                                                  .industrialPrimary,
                                              size: 18,
                                            ),
                                          )
                                        : null,
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              );
                            },
                            isWidget: true,
                          ),
                        ],
                        emptyMessage: 'Aucun matériau disponible',
                        isLoading: mvm.isLoading,
                        hasError: false,
                        onEdit: (MaterialPriceItem item) async {
                        
                          final currentValue = _priceControllers[item.materialId]?.text.trim();
                            final customPrice = currentValue?.isNotEmpty == true 
                                ? double.tryParse(currentValue!.replaceAll(',', '.'))
                                : null;
                            if(customPrice != null) {
                             bool success = await mvm.createClientMaterialPrice(
                                                        clientId: item.clientId,
                                                        materialId: item.materialId,
                                                        customPricePerTon: customPrice!,
                              );  
                              if(success){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Prix spécial enregistré')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Erreur lors de l'enregistrement du prix spécial")),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Veuillez entrer un prix valide')),
                              );
                            }
                                                    
                        },
                        onDelete: (MaterialPriceItem item) async  {
                          if(item.materialPriceId != null){
                      bool  success =  await  mvm.deleteClientMaterialPrice(priceId: item.materialPriceId!, clientId: item.clientId);
                          if(success){
                                ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(content: const Text('Prix spécial supprimé'),backgroundColor: AppColors.success,),
                                );
                                 _priceControllers[item.materialId]?.clear();
                                  setState(() {});
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Erreur lors de la suppression du prix spécial"),backgroundColor: AppColors.lightError,),
                                );
                              }
                          }
                        },
                          showCustomActionButton: false,
                      ),
                ),
              ),
            ),

            // Boutons d'action en bas
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.grey200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: _isSaving ? null : widget.onClose,
                    icon: const Icon(Icons.close),
                    label: const Text('Fermer'),
                  ),
                  const SizedBox(width: 12),
                  // SizedBox(
                  //   width: 120,
                  //   height: 40,
                  //   child: ElevatedButton.icon(
                  //     onPressed:
                  //         _isSaving ? null : () => _savePrices(context),
                  //     style: AppTheme.industrialPrimaryButton,
                  //     icon: _isSaving
                  //         ? const SizedBox(
                  //             width: 14,
                  //             height: 14,
                  //             child: CircularProgressIndicator(
                  //               strokeWidth: 2,
                  //               valueColor: AlwaysStoppedAnimation<Color>(
                  //                 AppColors.white,
                  //               ),
                  //             ),
                  //           )
                  //         : const Icon(Icons.save, size: 16),
                  //     label: const Text(
                  //       'Enregistrer',
                  //       style: TextStyle(fontSize: 12),
                  //     ),
                  //   ),
                  // ),
                
                
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
