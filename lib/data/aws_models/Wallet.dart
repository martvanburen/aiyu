/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;


/** This is an auto generated class representing the Wallet type in your schema. */
class Wallet extends amplify_core.Model {
  static const classType = const _WalletModelType();
  final String id;
  final String? _identity_id;
  final int? _balance_microcents;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  WalletModelIdentifier get modelIdentifier {
      return WalletModelIdentifier(
        id: id
      );
  }
  
  String get identity_id {
    try {
      return _identity_id!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get balance_microcents {
    try {
      return _balance_microcents!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Wallet._internal({required this.id, required identity_id, required balance_microcents, createdAt, updatedAt}): _identity_id = identity_id, _balance_microcents = balance_microcents, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Wallet({String? id, required String identity_id, required int balance_microcents}) {
    return Wallet._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      identity_id: identity_id,
      balance_microcents: balance_microcents);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Wallet &&
      id == other.id &&
      _identity_id == other._identity_id &&
      _balance_microcents == other._balance_microcents;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Wallet {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("identity_id=" + "$_identity_id" + ", ");
    buffer.write("balance_microcents=" + (_balance_microcents != null ? _balance_microcents!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Wallet copyWith({String? identity_id, int? balance_microcents}) {
    return Wallet._internal(
      id: id,
      identity_id: identity_id ?? this.identity_id,
      balance_microcents: balance_microcents ?? this.balance_microcents);
  }
  
  Wallet copyWithModelFieldValues({
    ModelFieldValue<String>? identity_id,
    ModelFieldValue<int>? balance_microcents
  }) {
    return Wallet._internal(
      id: id,
      identity_id: identity_id == null ? this.identity_id : identity_id.value,
      balance_microcents: balance_microcents == null ? this.balance_microcents : balance_microcents.value
    );
  }
  
  Wallet.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _identity_id = json['identity_id'],
      _balance_microcents = (json['balance_microcents'] as num?)?.toInt(),
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'identity_id': _identity_id, 'balance_microcents': _balance_microcents, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'identity_id': _identity_id,
    'balance_microcents': _balance_microcents,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<WalletModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<WalletModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final IDENTITY_ID = amplify_core.QueryField(fieldName: "identity_id");
  static final BALANCE_MICROCENTS = amplify_core.QueryField(fieldName: "balance_microcents");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Wallet";
    modelSchemaDefinition.pluralName = "Wallets";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.OWNER,
        ownerField: "owner",
        identityClaim: "cognito:username",
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ]),
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PUBLIC,
        provider: amplify_core.AuthRuleProvider.IAM,
        operations: const [
          amplify_core.ModelOperation.READ,
          amplify_core.ModelOperation.CREATE
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Wallet.IDENTITY_ID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Wallet.BALANCE_MICROCENTS,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _WalletModelType extends amplify_core.ModelType<Wallet> {
  const _WalletModelType();
  
  @override
  Wallet fromJson(Map<String, dynamic> jsonData) {
    return Wallet.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Wallet';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Wallet] in your schema.
 */
class WalletModelIdentifier implements amplify_core.ModelIdentifier<Wallet> {
  final String id;

  /** Create an instance of WalletModelIdentifier using [id] the primary key. */
  const WalletModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'WalletModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is WalletModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}