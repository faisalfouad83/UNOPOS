// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $StoresTable extends Stores with TableInfo<$StoresTable, Store> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeLoginIdMeta = const VerificationMeta(
    'storeLoginId',
  );
  @override
  late final GeneratedColumn<String> storeLoginId = GeneratedColumn<String>(
    'store_login_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
    'password_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activationCodeIdMeta = const VerificationMeta(
    'activationCodeId',
  );
  @override
  late final GeneratedColumn<String> activationCodeId = GeneratedColumn<String>(
    'activation_code_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeLoginId,
    passwordHash,
    displayName,
    activationCodeId,
    createdAt,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stores';
  @override
  VerificationContext validateIntegrity(
    Insertable<Store> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_login_id')) {
      context.handle(
        _storeLoginIdMeta,
        storeLoginId.isAcceptableOrUnknown(
          data['store_login_id']!,
          _storeLoginIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storeLoginIdMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('activation_code_id')) {
      context.handle(
        _activationCodeIdMeta,
        activationCodeId.isAcceptableOrUnknown(
          data['activation_code_id']!,
          _activationCodeIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Store map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Store(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeLoginId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_login_id'],
      )!,
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      activationCodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activation_code_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $StoresTable createAlias(String alias) {
    return $StoresTable(attachedDatabase, alias);
  }
}

class Store extends DataClass implements Insertable<Store> {
  final String id;
  final String storeLoginId;
  final String passwordHash;
  final String displayName;
  final String? activationCodeId;
  final DateTime createdAt;
  final bool isActive;
  const Store({
    required this.id,
    required this.storeLoginId,
    required this.passwordHash,
    required this.displayName,
    this.activationCodeId,
    required this.createdAt,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_login_id'] = Variable<String>(storeLoginId);
    map['password_hash'] = Variable<String>(passwordHash);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || activationCodeId != null) {
      map['activation_code_id'] = Variable<String>(activationCodeId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  StoresCompanion toCompanion(bool nullToAbsent) {
    return StoresCompanion(
      id: Value(id),
      storeLoginId: Value(storeLoginId),
      passwordHash: Value(passwordHash),
      displayName: Value(displayName),
      activationCodeId: activationCodeId == null && nullToAbsent
          ? const Value.absent()
          : Value(activationCodeId),
      createdAt: Value(createdAt),
      isActive: Value(isActive),
    );
  }

  factory Store.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Store(
      id: serializer.fromJson<String>(json['id']),
      storeLoginId: serializer.fromJson<String>(json['storeLoginId']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      displayName: serializer.fromJson<String>(json['displayName']),
      activationCodeId: serializer.fromJson<String?>(json['activationCodeId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeLoginId': serializer.toJson<String>(storeLoginId),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'displayName': serializer.toJson<String>(displayName),
      'activationCodeId': serializer.toJson<String?>(activationCodeId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Store copyWith({
    String? id,
    String? storeLoginId,
    String? passwordHash,
    String? displayName,
    Value<String?> activationCodeId = const Value.absent(),
    DateTime? createdAt,
    bool? isActive,
  }) => Store(
    id: id ?? this.id,
    storeLoginId: storeLoginId ?? this.storeLoginId,
    passwordHash: passwordHash ?? this.passwordHash,
    displayName: displayName ?? this.displayName,
    activationCodeId: activationCodeId.present
        ? activationCodeId.value
        : this.activationCodeId,
    createdAt: createdAt ?? this.createdAt,
    isActive: isActive ?? this.isActive,
  );
  Store copyWithCompanion(StoresCompanion data) {
    return Store(
      id: data.id.present ? data.id.value : this.id,
      storeLoginId: data.storeLoginId.present
          ? data.storeLoginId.value
          : this.storeLoginId,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      activationCodeId: data.activationCodeId.present
          ? data.activationCodeId.value
          : this.activationCodeId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Store(')
          ..write('id: $id, ')
          ..write('storeLoginId: $storeLoginId, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('displayName: $displayName, ')
          ..write('activationCodeId: $activationCodeId, ')
          ..write('createdAt: $createdAt, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeLoginId,
    passwordHash,
    displayName,
    activationCodeId,
    createdAt,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Store &&
          other.id == this.id &&
          other.storeLoginId == this.storeLoginId &&
          other.passwordHash == this.passwordHash &&
          other.displayName == this.displayName &&
          other.activationCodeId == this.activationCodeId &&
          other.createdAt == this.createdAt &&
          other.isActive == this.isActive);
}

class StoresCompanion extends UpdateCompanion<Store> {
  final Value<String> id;
  final Value<String> storeLoginId;
  final Value<String> passwordHash;
  final Value<String> displayName;
  final Value<String?> activationCodeId;
  final Value<DateTime> createdAt;
  final Value<bool> isActive;
  final Value<int> rowid;
  const StoresCompanion({
    this.id = const Value.absent(),
    this.storeLoginId = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.displayName = const Value.absent(),
    this.activationCodeId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoresCompanion.insert({
    required String id,
    required String storeLoginId,
    required String passwordHash,
    required String displayName,
    this.activationCodeId = const Value.absent(),
    required DateTime createdAt,
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeLoginId = Value(storeLoginId),
       passwordHash = Value(passwordHash),
       displayName = Value(displayName),
       createdAt = Value(createdAt);
  static Insertable<Store> custom({
    Expression<String>? id,
    Expression<String>? storeLoginId,
    Expression<String>? passwordHash,
    Expression<String>? displayName,
    Expression<String>? activationCodeId,
    Expression<DateTime>? createdAt,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeLoginId != null) 'store_login_id': storeLoginId,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (displayName != null) 'display_name': displayName,
      if (activationCodeId != null) 'activation_code_id': activationCodeId,
      if (createdAt != null) 'created_at': createdAt,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoresCompanion copyWith({
    Value<String>? id,
    Value<String>? storeLoginId,
    Value<String>? passwordHash,
    Value<String>? displayName,
    Value<String?>? activationCodeId,
    Value<DateTime>? createdAt,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return StoresCompanion(
      id: id ?? this.id,
      storeLoginId: storeLoginId ?? this.storeLoginId,
      passwordHash: passwordHash ?? this.passwordHash,
      displayName: displayName ?? this.displayName,
      activationCodeId: activationCodeId ?? this.activationCodeId,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeLoginId.present) {
      map['store_login_id'] = Variable<String>(storeLoginId.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (activationCodeId.present) {
      map['activation_code_id'] = Variable<String>(activationCodeId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoresCompanion(')
          ..write('id: $id, ')
          ..write('storeLoginId: $storeLoginId, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('displayName: $displayName, ')
          ..write('activationCodeId: $activationCodeId, ')
          ..write('createdAt: $createdAt, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BranchesTable extends Branches with TableInfo<$BranchesTable, Branch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BranchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isMainBranchMeta = const VerificationMeta(
    'isMainBranch',
  );
  @override
  late final GeneratedColumn<bool> isMainBranch = GeneratedColumn<bool>(
    'is_main_branch',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_main_branch" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    name,
    address,
    phone,
    isMainBranch,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'branches';
  @override
  VerificationContext validateIntegrity(
    Insertable<Branch> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('is_main_branch')) {
      context.handle(
        _isMainBranchMeta,
        isMainBranch.isAcceptableOrUnknown(
          data['is_main_branch']!,
          _isMainBranchMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Branch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Branch(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      isMainBranch: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_main_branch'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BranchesTable createAlias(String alias) {
    return $BranchesTable(attachedDatabase, alias);
  }
}

class Branch extends DataClass implements Insertable<Branch> {
  final String id;
  final String storeId;
  final String name;
  final String address;
  final String phone;
  final bool isMainBranch;
  final bool isActive;
  final DateTime createdAt;
  const Branch({
    required this.id,
    required this.storeId,
    required this.name,
    required this.address,
    required this.phone,
    required this.isMainBranch,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['name'] = Variable<String>(name);
    map['address'] = Variable<String>(address);
    map['phone'] = Variable<String>(phone);
    map['is_main_branch'] = Variable<bool>(isMainBranch);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BranchesCompanion toCompanion(bool nullToAbsent) {
    return BranchesCompanion(
      id: Value(id),
      storeId: Value(storeId),
      name: Value(name),
      address: Value(address),
      phone: Value(phone),
      isMainBranch: Value(isMainBranch),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Branch.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Branch(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String>(json['address']),
      phone: serializer.fromJson<String>(json['phone']),
      isMainBranch: serializer.fromJson<bool>(json['isMainBranch']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String>(address),
      'phone': serializer.toJson<String>(phone),
      'isMainBranch': serializer.toJson<bool>(isMainBranch),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Branch copyWith({
    String? id,
    String? storeId,
    String? name,
    String? address,
    String? phone,
    bool? isMainBranch,
    bool? isActive,
    DateTime? createdAt,
  }) => Branch(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    name: name ?? this.name,
    address: address ?? this.address,
    phone: phone ?? this.phone,
    isMainBranch: isMainBranch ?? this.isMainBranch,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  Branch copyWithCompanion(BranchesCompanion data) {
    return Branch(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      phone: data.phone.present ? data.phone.value : this.phone,
      isMainBranch: data.isMainBranch.present
          ? data.isMainBranch.value
          : this.isMainBranch,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Branch(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('isMainBranch: $isMainBranch, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    name,
    address,
    phone,
    isMainBranch,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Branch &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.name == this.name &&
          other.address == this.address &&
          other.phone == this.phone &&
          other.isMainBranch == this.isMainBranch &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class BranchesCompanion extends UpdateCompanion<Branch> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> name;
  final Value<String> address;
  final Value<String> phone;
  final Value<bool> isMainBranch;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BranchesCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.isMainBranch = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BranchesCompanion.insert({
    required String id,
    required String storeId,
    required String name,
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.isMainBranch = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Branch> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? name,
    Expression<String>? address,
    Expression<String>? phone,
    Expression<bool>? isMainBranch,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (isMainBranch != null) 'is_main_branch': isMainBranch,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BranchesCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? name,
    Value<String>? address,
    Value<String>? phone,
    Value<bool>? isMainBranch,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BranchesCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      isMainBranch: isMainBranch ?? this.isMainBranch,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (isMainBranch.present) {
      map['is_main_branch'] = Variable<bool>(isMainBranch.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BranchesCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('isMainBranch: $isMainBranch, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _branchIdMeta = const VerificationMeta(
    'branchId',
  );
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
    'branch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinHashMeta = const VerificationMeta(
    'pinHash',
  );
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
    'pin_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _salaryMinorUnitsMeta = const VerificationMeta(
    'salaryMinorUnits',
  );
  @override
  late final GeneratedColumn<int> salaryMinorUnits = GeneratedColumn<int>(
    'salary_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _allowancesMinorUnitsMeta =
      const VerificationMeta('allowancesMinorUnits');
  @override
  late final GeneratedColumn<int> allowancesMinorUnits = GeneratedColumn<int>(
    'allowances_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _avatarColorHexMeta = const VerificationMeta(
    'avatarColorHex',
  );
  @override
  late final GeneratedColumn<String> avatarColorHex = GeneratedColumn<String>(
    'avatar_color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#0F6E5C'),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    branchId,
    name,
    role,
    pinHash,
    phone,
    address,
    salaryMinorUnits,
    allowancesMinorUnits,
    avatarColorHex,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(
        _branchIdMeta,
        branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('pin_hash')) {
      context.handle(
        _pinHashMeta,
        pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta),
      );
    } else if (isInserting) {
      context.missing(_pinHashMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('salary_minor_units')) {
      context.handle(
        _salaryMinorUnitsMeta,
        salaryMinorUnits.isAcceptableOrUnknown(
          data['salary_minor_units']!,
          _salaryMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('allowances_minor_units')) {
      context.handle(
        _allowancesMinorUnitsMeta,
        allowancesMinorUnits.isAcceptableOrUnknown(
          data['allowances_minor_units']!,
          _allowancesMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('avatar_color_hex')) {
      context.handle(
        _avatarColorHexMeta,
        avatarColorHex.isAcceptableOrUnknown(
          data['avatar_color_hex']!,
          _avatarColorHexMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      branchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      pinHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_hash'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      salaryMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}salary_minor_units'],
      )!,
      allowancesMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}allowances_minor_units'],
      )!,
      avatarColorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_color_hex'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String storeId;
  final String? branchId;
  final String name;
  final String role;
  final String pinHash;
  final String phone;
  final String address;

  /// Salary/allowances live here (not a separate HR table) since an
  /// employee IS the HR record; the HR feature is just a role-gated view
  /// over this same table with extra fields visible.
  final int salaryMinorUnits;
  final int allowancesMinorUnits;
  final String avatarColorHex;
  final bool isActive;
  final DateTime createdAt;
  const User({
    required this.id,
    required this.storeId,
    this.branchId,
    required this.name,
    required this.role,
    required this.pinHash,
    required this.phone,
    required this.address,
    required this.salaryMinorUnits,
    required this.allowancesMinorUnits,
    required this.avatarColorHex,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    if (!nullToAbsent || branchId != null) {
      map['branch_id'] = Variable<String>(branchId);
    }
    map['name'] = Variable<String>(name);
    map['role'] = Variable<String>(role);
    map['pin_hash'] = Variable<String>(pinHash);
    map['phone'] = Variable<String>(phone);
    map['address'] = Variable<String>(address);
    map['salary_minor_units'] = Variable<int>(salaryMinorUnits);
    map['allowances_minor_units'] = Variable<int>(allowancesMinorUnits);
    map['avatar_color_hex'] = Variable<String>(avatarColorHex);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      storeId: Value(storeId),
      branchId: branchId == null && nullToAbsent
          ? const Value.absent()
          : Value(branchId),
      name: Value(name),
      role: Value(role),
      pinHash: Value(pinHash),
      phone: Value(phone),
      address: Value(address),
      salaryMinorUnits: Value(salaryMinorUnits),
      allowancesMinorUnits: Value(allowancesMinorUnits),
      avatarColorHex: Value(avatarColorHex),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      branchId: serializer.fromJson<String?>(json['branchId']),
      name: serializer.fromJson<String>(json['name']),
      role: serializer.fromJson<String>(json['role']),
      pinHash: serializer.fromJson<String>(json['pinHash']),
      phone: serializer.fromJson<String>(json['phone']),
      address: serializer.fromJson<String>(json['address']),
      salaryMinorUnits: serializer.fromJson<int>(json['salaryMinorUnits']),
      allowancesMinorUnits: serializer.fromJson<int>(
        json['allowancesMinorUnits'],
      ),
      avatarColorHex: serializer.fromJson<String>(json['avatarColorHex']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'branchId': serializer.toJson<String?>(branchId),
      'name': serializer.toJson<String>(name),
      'role': serializer.toJson<String>(role),
      'pinHash': serializer.toJson<String>(pinHash),
      'phone': serializer.toJson<String>(phone),
      'address': serializer.toJson<String>(address),
      'salaryMinorUnits': serializer.toJson<int>(salaryMinorUnits),
      'allowancesMinorUnits': serializer.toJson<int>(allowancesMinorUnits),
      'avatarColorHex': serializer.toJson<String>(avatarColorHex),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  User copyWith({
    String? id,
    String? storeId,
    Value<String?> branchId = const Value.absent(),
    String? name,
    String? role,
    String? pinHash,
    String? phone,
    String? address,
    int? salaryMinorUnits,
    int? allowancesMinorUnits,
    String? avatarColorHex,
    bool? isActive,
    DateTime? createdAt,
  }) => User(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    branchId: branchId.present ? branchId.value : this.branchId,
    name: name ?? this.name,
    role: role ?? this.role,
    pinHash: pinHash ?? this.pinHash,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    salaryMinorUnits: salaryMinorUnits ?? this.salaryMinorUnits,
    allowancesMinorUnits: allowancesMinorUnits ?? this.allowancesMinorUnits,
    avatarColorHex: avatarColorHex ?? this.avatarColorHex,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      name: data.name.present ? data.name.value : this.name,
      role: data.role.present ? data.role.value : this.role,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      phone: data.phone.present ? data.phone.value : this.phone,
      address: data.address.present ? data.address.value : this.address,
      salaryMinorUnits: data.salaryMinorUnits.present
          ? data.salaryMinorUnits.value
          : this.salaryMinorUnits,
      allowancesMinorUnits: data.allowancesMinorUnits.present
          ? data.allowancesMinorUnits.value
          : this.allowancesMinorUnits,
      avatarColorHex: data.avatarColorHex.present
          ? data.avatarColorHex.value
          : this.avatarColorHex,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('branchId: $branchId, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('pinHash: $pinHash, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('salaryMinorUnits: $salaryMinorUnits, ')
          ..write('allowancesMinorUnits: $allowancesMinorUnits, ')
          ..write('avatarColorHex: $avatarColorHex, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    branchId,
    name,
    role,
    pinHash,
    phone,
    address,
    salaryMinorUnits,
    allowancesMinorUnits,
    avatarColorHex,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.branchId == this.branchId &&
          other.name == this.name &&
          other.role == this.role &&
          other.pinHash == this.pinHash &&
          other.phone == this.phone &&
          other.address == this.address &&
          other.salaryMinorUnits == this.salaryMinorUnits &&
          other.allowancesMinorUnits == this.allowancesMinorUnits &&
          other.avatarColorHex == this.avatarColorHex &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String?> branchId;
  final Value<String> name;
  final Value<String> role;
  final Value<String> pinHash;
  final Value<String> phone;
  final Value<String> address;
  final Value<int> salaryMinorUnits;
  final Value<int> allowancesMinorUnits;
  final Value<String> avatarColorHex;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.branchId = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.salaryMinorUnits = const Value.absent(),
    this.allowancesMinorUnits = const Value.absent(),
    this.avatarColorHex = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String storeId,
    this.branchId = const Value.absent(),
    required String name,
    required String role,
    required String pinHash,
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.salaryMinorUnits = const Value.absent(),
    this.allowancesMinorUnits = const Value.absent(),
    this.avatarColorHex = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       name = Value(name),
       role = Value(role),
       pinHash = Value(pinHash),
       createdAt = Value(createdAt);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? branchId,
    Expression<String>? name,
    Expression<String>? role,
    Expression<String>? pinHash,
    Expression<String>? phone,
    Expression<String>? address,
    Expression<int>? salaryMinorUnits,
    Expression<int>? allowancesMinorUnits,
    Expression<String>? avatarColorHex,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (branchId != null) 'branch_id': branchId,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (pinHash != null) 'pin_hash': pinHash,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (salaryMinorUnits != null) 'salary_minor_units': salaryMinorUnits,
      if (allowancesMinorUnits != null)
        'allowances_minor_units': allowancesMinorUnits,
      if (avatarColorHex != null) 'avatar_color_hex': avatarColorHex,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String?>? branchId,
    Value<String>? name,
    Value<String>? role,
    Value<String>? pinHash,
    Value<String>? phone,
    Value<String>? address,
    Value<int>? salaryMinorUnits,
    Value<int>? allowancesMinorUnits,
    Value<String>? avatarColorHex,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      branchId: branchId ?? this.branchId,
      name: name ?? this.name,
      role: role ?? this.role,
      pinHash: pinHash ?? this.pinHash,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      salaryMinorUnits: salaryMinorUnits ?? this.salaryMinorUnits,
      allowancesMinorUnits: allowancesMinorUnits ?? this.allowancesMinorUnits,
      avatarColorHex: avatarColorHex ?? this.avatarColorHex,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (salaryMinorUnits.present) {
      map['salary_minor_units'] = Variable<int>(salaryMinorUnits.value);
    }
    if (allowancesMinorUnits.present) {
      map['allowances_minor_units'] = Variable<int>(allowancesMinorUnits.value);
    }
    if (avatarColorHex.present) {
      map['avatar_color_hex'] = Variable<String>(avatarColorHex.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('branchId: $branchId, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('pinHash: $pinHash, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('salaryMinorUnits: $salaryMinorUnits, ')
          ..write('allowancesMinorUnits: $allowancesMinorUnits, ')
          ..write('avatarColorHex: $avatarColorHex, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivationCodesTable extends ActivationCodes
    with TableInfo<$ActivationCodesTable, ActivationCode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivationCodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _storeNameRefMeta = const VerificationMeta(
    'storeNameRef',
  );
  @override
  late final GeneratedColumn<String> storeNameRef = GeneratedColumn<String>(
    'store_name_ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  @override
  late final GeneratedColumn<String> tier = GeneratedColumn<String>(
    'tier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _issuedAtMeta = const VerificationMeta(
    'issuedAt',
  );
  @override
  late final GeneratedColumn<DateTime> issuedAt = GeneratedColumn<DateTime>(
    'issued_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unused'),
  );
  static const VerificationMeta _redeemedByStoreIdMeta = const VerificationMeta(
    'redeemedByStoreId',
  );
  @override
  late final GeneratedColumn<String> redeemedByStoreId =
      GeneratedColumn<String>(
        'redeemed_by_store_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _redeemedAtMeta = const VerificationMeta(
    'redeemedAt',
  );
  @override
  late final GeneratedColumn<DateTime> redeemedAt = GeneratedColumn<DateTime>(
    'redeemed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    storeNameRef,
    tier,
    issuedAt,
    expiresAt,
    status,
    redeemedByStoreId,
    redeemedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activation_codes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivationCode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('store_name_ref')) {
      context.handle(
        _storeNameRefMeta,
        storeNameRef.isAcceptableOrUnknown(
          data['store_name_ref']!,
          _storeNameRefMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storeNameRefMeta);
    }
    if (data.containsKey('tier')) {
      context.handle(
        _tierMeta,
        tier.isAcceptableOrUnknown(data['tier']!, _tierMeta),
      );
    } else if (isInserting) {
      context.missing(_tierMeta);
    }
    if (data.containsKey('issued_at')) {
      context.handle(
        _issuedAtMeta,
        issuedAt.isAcceptableOrUnknown(data['issued_at']!, _issuedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_issuedAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('redeemed_by_store_id')) {
      context.handle(
        _redeemedByStoreIdMeta,
        redeemedByStoreId.isAcceptableOrUnknown(
          data['redeemed_by_store_id']!,
          _redeemedByStoreIdMeta,
        ),
      );
    }
    if (data.containsKey('redeemed_at')) {
      context.handle(
        _redeemedAtMeta,
        redeemedAt.isAcceptableOrUnknown(data['redeemed_at']!, _redeemedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivationCode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivationCode(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      storeNameRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_name_ref'],
      )!,
      tier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tier'],
      )!,
      issuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}issued_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      redeemedByStoreId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}redeemed_by_store_id'],
      ),
      redeemedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}redeemed_at'],
      ),
    );
  }

  @override
  $ActivationCodesTable createAlias(String alias) {
    return $ActivationCodesTable(attachedDatabase, alias);
  }
}

class ActivationCode extends DataClass implements Insertable<ActivationCode> {
  final String id;
  final String code;
  final String storeNameRef;
  final String tier;
  final DateTime issuedAt;
  final DateTime? expiresAt;
  final String status;
  final String? redeemedByStoreId;
  final DateTime? redeemedAt;
  const ActivationCode({
    required this.id,
    required this.code,
    required this.storeNameRef,
    required this.tier,
    required this.issuedAt,
    this.expiresAt,
    required this.status,
    this.redeemedByStoreId,
    this.redeemedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['store_name_ref'] = Variable<String>(storeNameRef);
    map['tier'] = Variable<String>(tier);
    map['issued_at'] = Variable<DateTime>(issuedAt);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || redeemedByStoreId != null) {
      map['redeemed_by_store_id'] = Variable<String>(redeemedByStoreId);
    }
    if (!nullToAbsent || redeemedAt != null) {
      map['redeemed_at'] = Variable<DateTime>(redeemedAt);
    }
    return map;
  }

  ActivationCodesCompanion toCompanion(bool nullToAbsent) {
    return ActivationCodesCompanion(
      id: Value(id),
      code: Value(code),
      storeNameRef: Value(storeNameRef),
      tier: Value(tier),
      issuedAt: Value(issuedAt),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      status: Value(status),
      redeemedByStoreId: redeemedByStoreId == null && nullToAbsent
          ? const Value.absent()
          : Value(redeemedByStoreId),
      redeemedAt: redeemedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(redeemedAt),
    );
  }

  factory ActivationCode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivationCode(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      storeNameRef: serializer.fromJson<String>(json['storeNameRef']),
      tier: serializer.fromJson<String>(json['tier']),
      issuedAt: serializer.fromJson<DateTime>(json['issuedAt']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
      status: serializer.fromJson<String>(json['status']),
      redeemedByStoreId: serializer.fromJson<String?>(
        json['redeemedByStoreId'],
      ),
      redeemedAt: serializer.fromJson<DateTime?>(json['redeemedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'storeNameRef': serializer.toJson<String>(storeNameRef),
      'tier': serializer.toJson<String>(tier),
      'issuedAt': serializer.toJson<DateTime>(issuedAt),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
      'status': serializer.toJson<String>(status),
      'redeemedByStoreId': serializer.toJson<String?>(redeemedByStoreId),
      'redeemedAt': serializer.toJson<DateTime?>(redeemedAt),
    };
  }

  ActivationCode copyWith({
    String? id,
    String? code,
    String? storeNameRef,
    String? tier,
    DateTime? issuedAt,
    Value<DateTime?> expiresAt = const Value.absent(),
    String? status,
    Value<String?> redeemedByStoreId = const Value.absent(),
    Value<DateTime?> redeemedAt = const Value.absent(),
  }) => ActivationCode(
    id: id ?? this.id,
    code: code ?? this.code,
    storeNameRef: storeNameRef ?? this.storeNameRef,
    tier: tier ?? this.tier,
    issuedAt: issuedAt ?? this.issuedAt,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    status: status ?? this.status,
    redeemedByStoreId: redeemedByStoreId.present
        ? redeemedByStoreId.value
        : this.redeemedByStoreId,
    redeemedAt: redeemedAt.present ? redeemedAt.value : this.redeemedAt,
  );
  ActivationCode copyWithCompanion(ActivationCodesCompanion data) {
    return ActivationCode(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      storeNameRef: data.storeNameRef.present
          ? data.storeNameRef.value
          : this.storeNameRef,
      tier: data.tier.present ? data.tier.value : this.tier,
      issuedAt: data.issuedAt.present ? data.issuedAt.value : this.issuedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      status: data.status.present ? data.status.value : this.status,
      redeemedByStoreId: data.redeemedByStoreId.present
          ? data.redeemedByStoreId.value
          : this.redeemedByStoreId,
      redeemedAt: data.redeemedAt.present
          ? data.redeemedAt.value
          : this.redeemedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivationCode(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('storeNameRef: $storeNameRef, ')
          ..write('tier: $tier, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('status: $status, ')
          ..write('redeemedByStoreId: $redeemedByStoreId, ')
          ..write('redeemedAt: $redeemedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    storeNameRef,
    tier,
    issuedAt,
    expiresAt,
    status,
    redeemedByStoreId,
    redeemedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivationCode &&
          other.id == this.id &&
          other.code == this.code &&
          other.storeNameRef == this.storeNameRef &&
          other.tier == this.tier &&
          other.issuedAt == this.issuedAt &&
          other.expiresAt == this.expiresAt &&
          other.status == this.status &&
          other.redeemedByStoreId == this.redeemedByStoreId &&
          other.redeemedAt == this.redeemedAt);
}

class ActivationCodesCompanion extends UpdateCompanion<ActivationCode> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> storeNameRef;
  final Value<String> tier;
  final Value<DateTime> issuedAt;
  final Value<DateTime?> expiresAt;
  final Value<String> status;
  final Value<String?> redeemedByStoreId;
  final Value<DateTime?> redeemedAt;
  final Value<int> rowid;
  const ActivationCodesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.storeNameRef = const Value.absent(),
    this.tier = const Value.absent(),
    this.issuedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.status = const Value.absent(),
    this.redeemedByStoreId = const Value.absent(),
    this.redeemedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivationCodesCompanion.insert({
    required String id,
    required String code,
    required String storeNameRef,
    required String tier,
    required DateTime issuedAt,
    this.expiresAt = const Value.absent(),
    this.status = const Value.absent(),
    this.redeemedByStoreId = const Value.absent(),
    this.redeemedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       storeNameRef = Value(storeNameRef),
       tier = Value(tier),
       issuedAt = Value(issuedAt);
  static Insertable<ActivationCode> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? storeNameRef,
    Expression<String>? tier,
    Expression<DateTime>? issuedAt,
    Expression<DateTime>? expiresAt,
    Expression<String>? status,
    Expression<String>? redeemedByStoreId,
    Expression<DateTime>? redeemedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (storeNameRef != null) 'store_name_ref': storeNameRef,
      if (tier != null) 'tier': tier,
      if (issuedAt != null) 'issued_at': issuedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (status != null) 'status': status,
      if (redeemedByStoreId != null) 'redeemed_by_store_id': redeemedByStoreId,
      if (redeemedAt != null) 'redeemed_at': redeemedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivationCodesCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? storeNameRef,
    Value<String>? tier,
    Value<DateTime>? issuedAt,
    Value<DateTime?>? expiresAt,
    Value<String>? status,
    Value<String?>? redeemedByStoreId,
    Value<DateTime?>? redeemedAt,
    Value<int>? rowid,
  }) {
    return ActivationCodesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      storeNameRef: storeNameRef ?? this.storeNameRef,
      tier: tier ?? this.tier,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      redeemedByStoreId: redeemedByStoreId ?? this.redeemedByStoreId,
      redeemedAt: redeemedAt ?? this.redeemedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (storeNameRef.present) {
      map['store_name_ref'] = Variable<String>(storeNameRef.value);
    }
    if (tier.present) {
      map['tier'] = Variable<String>(tier.value);
    }
    if (issuedAt.present) {
      map['issued_at'] = Variable<DateTime>(issuedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (redeemedByStoreId.present) {
      map['redeemed_by_store_id'] = Variable<String>(redeemedByStoreId.value);
    }
    if (redeemedAt.present) {
      map['redeemed_at'] = Variable<DateTime>(redeemedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivationCodesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('storeNameRef: $storeNameRef, ')
          ..write('tier: $tier, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('status: $status, ')
          ..write('redeemedByStoreId: $redeemedByStoreId, ')
          ..write('redeemedAt: $redeemedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentCategoryIdMeta = const VerificationMeta(
    'parentCategoryId',
  );
  @override
  late final GeneratedColumn<String> parentCategoryId = GeneratedColumn<String>(
    'parent_category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, storeId, name, parentCategoryId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parent_category_id')) {
      context.handle(
        _parentCategoryIdMeta,
        parentCategoryId.isAcceptableOrUnknown(
          data['parent_category_id']!,
          _parentCategoryIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      parentCategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_category_id'],
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String storeId;
  final String name;
  final String? parentCategoryId;
  const Category({
    required this.id,
    required this.storeId,
    required this.name,
    this.parentCategoryId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || parentCategoryId != null) {
      map['parent_category_id'] = Variable<String>(parentCategoryId);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      storeId: Value(storeId),
      name: Value(name),
      parentCategoryId: parentCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentCategoryId),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      name: serializer.fromJson<String>(json['name']),
      parentCategoryId: serializer.fromJson<String?>(json['parentCategoryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'name': serializer.toJson<String>(name),
      'parentCategoryId': serializer.toJson<String?>(parentCategoryId),
    };
  }

  Category copyWith({
    String? id,
    String? storeId,
    String? name,
    Value<String?> parentCategoryId = const Value.absent(),
  }) => Category(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    name: name ?? this.name,
    parentCategoryId: parentCategoryId.present
        ? parentCategoryId.value
        : this.parentCategoryId,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      name: data.name.present ? data.name.value : this.name,
      parentCategoryId: data.parentCategoryId.present
          ? data.parentCategoryId.value
          : this.parentCategoryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('name: $name, ')
          ..write('parentCategoryId: $parentCategoryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, storeId, name, parentCategoryId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.name == this.name &&
          other.parentCategoryId == this.parentCategoryId);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> name;
  final Value<String?> parentCategoryId;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.name = const Value.absent(),
    this.parentCategoryId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String storeId,
    required String name,
    this.parentCategoryId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       name = Value(name);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? name,
    Expression<String>? parentCategoryId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (name != null) 'name': name,
      if (parentCategoryId != null) 'parent_category_id': parentCategoryId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? name,
    Value<String?>? parentCategoryId,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parentCategoryId.present) {
      map['parent_category_id'] = Variable<String>(parentCategoryId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('name: $name, ')
          ..write('parentCategoryId: $parentCategoryId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaxRatesTable extends TaxRates with TableInfo<$TaxRatesTable, TaxRate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaxRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratePercentMeta = const VerificationMeta(
    'ratePercent',
  );
  @override
  late final GeneratedColumn<double> ratePercent = GeneratedColumn<double>(
    'rate_percent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    name,
    ratePercent,
    isDefault,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tax_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaxRate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('rate_percent')) {
      context.handle(
        _ratePercentMeta,
        ratePercent.isAcceptableOrUnknown(
          data['rate_percent']!,
          _ratePercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ratePercentMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaxRate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaxRate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      ratePercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate_percent'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
    );
  }

  @override
  $TaxRatesTable createAlias(String alias) {
    return $TaxRatesTable(attachedDatabase, alias);
  }
}

class TaxRate extends DataClass implements Insertable<TaxRate> {
  final String id;
  final String storeId;
  final String name;
  final double ratePercent;
  final bool isDefault;
  const TaxRate({
    required this.id,
    required this.storeId,
    required this.name,
    required this.ratePercent,
    required this.isDefault,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['name'] = Variable<String>(name);
    map['rate_percent'] = Variable<double>(ratePercent);
    map['is_default'] = Variable<bool>(isDefault);
    return map;
  }

  TaxRatesCompanion toCompanion(bool nullToAbsent) {
    return TaxRatesCompanion(
      id: Value(id),
      storeId: Value(storeId),
      name: Value(name),
      ratePercent: Value(ratePercent),
      isDefault: Value(isDefault),
    );
  }

  factory TaxRate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaxRate(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      name: serializer.fromJson<String>(json['name']),
      ratePercent: serializer.fromJson<double>(json['ratePercent']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'name': serializer.toJson<String>(name),
      'ratePercent': serializer.toJson<double>(ratePercent),
      'isDefault': serializer.toJson<bool>(isDefault),
    };
  }

  TaxRate copyWith({
    String? id,
    String? storeId,
    String? name,
    double? ratePercent,
    bool? isDefault,
  }) => TaxRate(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    name: name ?? this.name,
    ratePercent: ratePercent ?? this.ratePercent,
    isDefault: isDefault ?? this.isDefault,
  );
  TaxRate copyWithCompanion(TaxRatesCompanion data) {
    return TaxRate(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      name: data.name.present ? data.name.value : this.name,
      ratePercent: data.ratePercent.present
          ? data.ratePercent.value
          : this.ratePercent,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaxRate(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('name: $name, ')
          ..write('ratePercent: $ratePercent, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, storeId, name, ratePercent, isDefault);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaxRate &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.name == this.name &&
          other.ratePercent == this.ratePercent &&
          other.isDefault == this.isDefault);
}

class TaxRatesCompanion extends UpdateCompanion<TaxRate> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> name;
  final Value<double> ratePercent;
  final Value<bool> isDefault;
  final Value<int> rowid;
  const TaxRatesCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.name = const Value.absent(),
    this.ratePercent = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaxRatesCompanion.insert({
    required String id,
    required String storeId,
    required String name,
    required double ratePercent,
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       name = Value(name),
       ratePercent = Value(ratePercent);
  static Insertable<TaxRate> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? name,
    Expression<double>? ratePercent,
    Expression<bool>? isDefault,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (name != null) 'name': name,
      if (ratePercent != null) 'rate_percent': ratePercent,
      if (isDefault != null) 'is_default': isDefault,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaxRatesCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? name,
    Value<double>? ratePercent,
    Value<bool>? isDefault,
    Value<int>? rowid,
  }) {
    return TaxRatesCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      ratePercent: ratePercent ?? this.ratePercent,
      isDefault: isDefault ?? this.isDefault,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (ratePercent.present) {
      map['rate_percent'] = Variable<double>(ratePercent.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaxRatesCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('name: $name, ')
          ..write('ratePercent: $ratePercent, ')
          ..write('isDefault: $isDefault, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pcs'),
  );
  static const VerificationMeta _costPriceMinorUnitsMeta =
      const VerificationMeta('costPriceMinorUnits');
  @override
  late final GeneratedColumn<int> costPriceMinorUnits = GeneratedColumn<int>(
    'cost_price_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sellPriceMinorUnitsMeta =
      const VerificationMeta('sellPriceMinorUnits');
  @override
  late final GeneratedColumn<int> sellPriceMinorUnits = GeneratedColumn<int>(
    'sell_price_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _taxRateIdMeta = const VerificationMeta(
    'taxRateId',
  );
  @override
  late final GeneratedColumn<String> taxRateId = GeneratedColumn<String>(
    'tax_rate_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reorderLevelMeta = const VerificationMeta(
    'reorderLevel',
  );
  @override
  late final GeneratedColumn<int> reorderLevel = GeneratedColumn<int>(
    'reorder_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    categoryId,
    sku,
    barcode,
    name,
    unit,
    costPriceMinorUnits,
    sellPriceMinorUnits,
    taxRateId,
    reorderLevel,
    imagePath,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<Product> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
      );
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('cost_price_minor_units')) {
      context.handle(
        _costPriceMinorUnitsMeta,
        costPriceMinorUnits.isAcceptableOrUnknown(
          data['cost_price_minor_units']!,
          _costPriceMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('sell_price_minor_units')) {
      context.handle(
        _sellPriceMinorUnitsMeta,
        sellPriceMinorUnits.isAcceptableOrUnknown(
          data['sell_price_minor_units']!,
          _sellPriceMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('tax_rate_id')) {
      context.handle(
        _taxRateIdMeta,
        taxRateId.isAcceptableOrUnknown(data['tax_rate_id']!, _taxRateIdMeta),
      );
    }
    if (data.containsKey('reorder_level')) {
      context.handle(
        _reorderLevelMeta,
        reorderLevel.isAcceptableOrUnknown(
          data['reorder_level']!,
          _reorderLevelMeta,
        ),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      costPriceMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost_price_minor_units'],
      )!,
      sellPriceMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sell_price_minor_units'],
      )!,
      taxRateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tax_rate_id'],
      ),
      reorderLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reorder_level'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final String id;
  final String storeId;
  final String? categoryId;
  final String sku;
  final String? barcode;
  final String name;
  final String unit;
  final int costPriceMinorUnits;
  final int sellPriceMinorUnits;
  final String? taxRateId;
  final int reorderLevel;
  final String? imagePath;
  final bool isActive;
  final DateTime createdAt;
  const Product({
    required this.id,
    required this.storeId,
    this.categoryId,
    required this.sku,
    this.barcode,
    required this.name,
    required this.unit,
    required this.costPriceMinorUnits,
    required this.sellPriceMinorUnits,
    this.taxRateId,
    required this.reorderLevel,
    this.imagePath,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['sku'] = Variable<String>(sku);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['name'] = Variable<String>(name);
    map['unit'] = Variable<String>(unit);
    map['cost_price_minor_units'] = Variable<int>(costPriceMinorUnits);
    map['sell_price_minor_units'] = Variable<int>(sellPriceMinorUnits);
    if (!nullToAbsent || taxRateId != null) {
      map['tax_rate_id'] = Variable<String>(taxRateId);
    }
    map['reorder_level'] = Variable<int>(reorderLevel);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      storeId: Value(storeId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      sku: Value(sku),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      name: Value(name),
      unit: Value(unit),
      costPriceMinorUnits: Value(costPriceMinorUnits),
      sellPriceMinorUnits: Value(sellPriceMinorUnits),
      taxRateId: taxRateId == null && nullToAbsent
          ? const Value.absent()
          : Value(taxRateId),
      reorderLevel: Value(reorderLevel),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Product.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      sku: serializer.fromJson<String>(json['sku']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      name: serializer.fromJson<String>(json['name']),
      unit: serializer.fromJson<String>(json['unit']),
      costPriceMinorUnits: serializer.fromJson<int>(
        json['costPriceMinorUnits'],
      ),
      sellPriceMinorUnits: serializer.fromJson<int>(
        json['sellPriceMinorUnits'],
      ),
      taxRateId: serializer.fromJson<String?>(json['taxRateId']),
      reorderLevel: serializer.fromJson<int>(json['reorderLevel']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'categoryId': serializer.toJson<String?>(categoryId),
      'sku': serializer.toJson<String>(sku),
      'barcode': serializer.toJson<String?>(barcode),
      'name': serializer.toJson<String>(name),
      'unit': serializer.toJson<String>(unit),
      'costPriceMinorUnits': serializer.toJson<int>(costPriceMinorUnits),
      'sellPriceMinorUnits': serializer.toJson<int>(sellPriceMinorUnits),
      'taxRateId': serializer.toJson<String?>(taxRateId),
      'reorderLevel': serializer.toJson<int>(reorderLevel),
      'imagePath': serializer.toJson<String?>(imagePath),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Product copyWith({
    String? id,
    String? storeId,
    Value<String?> categoryId = const Value.absent(),
    String? sku,
    Value<String?> barcode = const Value.absent(),
    String? name,
    String? unit,
    int? costPriceMinorUnits,
    int? sellPriceMinorUnits,
    Value<String?> taxRateId = const Value.absent(),
    int? reorderLevel,
    Value<String?> imagePath = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
  }) => Product(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    sku: sku ?? this.sku,
    barcode: barcode.present ? barcode.value : this.barcode,
    name: name ?? this.name,
    unit: unit ?? this.unit,
    costPriceMinorUnits: costPriceMinorUnits ?? this.costPriceMinorUnits,
    sellPriceMinorUnits: sellPriceMinorUnits ?? this.sellPriceMinorUnits,
    taxRateId: taxRateId.present ? taxRateId.value : this.taxRateId,
    reorderLevel: reorderLevel ?? this.reorderLevel,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      sku: data.sku.present ? data.sku.value : this.sku,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      name: data.name.present ? data.name.value : this.name,
      unit: data.unit.present ? data.unit.value : this.unit,
      costPriceMinorUnits: data.costPriceMinorUnits.present
          ? data.costPriceMinorUnits.value
          : this.costPriceMinorUnits,
      sellPriceMinorUnits: data.sellPriceMinorUnits.present
          ? data.sellPriceMinorUnits.value
          : this.sellPriceMinorUnits,
      taxRateId: data.taxRateId.present ? data.taxRateId.value : this.taxRateId,
      reorderLevel: data.reorderLevel.present
          ? data.reorderLevel.value
          : this.reorderLevel,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('categoryId: $categoryId, ')
          ..write('sku: $sku, ')
          ..write('barcode: $barcode, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('costPriceMinorUnits: $costPriceMinorUnits, ')
          ..write('sellPriceMinorUnits: $sellPriceMinorUnits, ')
          ..write('taxRateId: $taxRateId, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('imagePath: $imagePath, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    categoryId,
    sku,
    barcode,
    name,
    unit,
    costPriceMinorUnits,
    sellPriceMinorUnits,
    taxRateId,
    reorderLevel,
    imagePath,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.categoryId == this.categoryId &&
          other.sku == this.sku &&
          other.barcode == this.barcode &&
          other.name == this.name &&
          other.unit == this.unit &&
          other.costPriceMinorUnits == this.costPriceMinorUnits &&
          other.sellPriceMinorUnits == this.sellPriceMinorUnits &&
          other.taxRateId == this.taxRateId &&
          other.reorderLevel == this.reorderLevel &&
          other.imagePath == this.imagePath &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String?> categoryId;
  final Value<String> sku;
  final Value<String?> barcode;
  final Value<String> name;
  final Value<String> unit;
  final Value<int> costPriceMinorUnits;
  final Value<int> sellPriceMinorUnits;
  final Value<String?> taxRateId;
  final Value<int> reorderLevel;
  final Value<String?> imagePath;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.sku = const Value.absent(),
    this.barcode = const Value.absent(),
    this.name = const Value.absent(),
    this.unit = const Value.absent(),
    this.costPriceMinorUnits = const Value.absent(),
    this.sellPriceMinorUnits = const Value.absent(),
    this.taxRateId = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String storeId,
    this.categoryId = const Value.absent(),
    required String sku,
    this.barcode = const Value.absent(),
    required String name,
    this.unit = const Value.absent(),
    this.costPriceMinorUnits = const Value.absent(),
    this.sellPriceMinorUnits = const Value.absent(),
    this.taxRateId = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       sku = Value(sku),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Product> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? categoryId,
    Expression<String>? sku,
    Expression<String>? barcode,
    Expression<String>? name,
    Expression<String>? unit,
    Expression<int>? costPriceMinorUnits,
    Expression<int>? sellPriceMinorUnits,
    Expression<String>? taxRateId,
    Expression<int>? reorderLevel,
    Expression<String>? imagePath,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (categoryId != null) 'category_id': categoryId,
      if (sku != null) 'sku': sku,
      if (barcode != null) 'barcode': barcode,
      if (name != null) 'name': name,
      if (unit != null) 'unit': unit,
      if (costPriceMinorUnits != null)
        'cost_price_minor_units': costPriceMinorUnits,
      if (sellPriceMinorUnits != null)
        'sell_price_minor_units': sellPriceMinorUnits,
      if (taxRateId != null) 'tax_rate_id': taxRateId,
      if (reorderLevel != null) 'reorder_level': reorderLevel,
      if (imagePath != null) 'image_path': imagePath,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String?>? categoryId,
    Value<String>? sku,
    Value<String?>? barcode,
    Value<String>? name,
    Value<String>? unit,
    Value<int>? costPriceMinorUnits,
    Value<int>? sellPriceMinorUnits,
    Value<String?>? taxRateId,
    Value<int>? reorderLevel,
    Value<String?>? imagePath,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      categoryId: categoryId ?? this.categoryId,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      costPriceMinorUnits: costPriceMinorUnits ?? this.costPriceMinorUnits,
      sellPriceMinorUnits: sellPriceMinorUnits ?? this.sellPriceMinorUnits,
      taxRateId: taxRateId ?? this.taxRateId,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      imagePath: imagePath ?? this.imagePath,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (costPriceMinorUnits.present) {
      map['cost_price_minor_units'] = Variable<int>(costPriceMinorUnits.value);
    }
    if (sellPriceMinorUnits.present) {
      map['sell_price_minor_units'] = Variable<int>(sellPriceMinorUnits.value);
    }
    if (taxRateId.present) {
      map['tax_rate_id'] = Variable<String>(taxRateId.value);
    }
    if (reorderLevel.present) {
      map['reorder_level'] = Variable<int>(reorderLevel.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('categoryId: $categoryId, ')
          ..write('sku: $sku, ')
          ..write('barcode: $barcode, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('costPriceMinorUnits: $costPriceMinorUnits, ')
          ..write('sellPriceMinorUnits: $sellPriceMinorUnits, ')
          ..write('taxRateId: $taxRateId, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('imagePath: $imagePath, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockItemsTable extends StockItems
    with TableInfo<$StockItemsTable, StockItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _branchIdMeta = const VerificationMeta(
    'branchId',
  );
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
    'branch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityOnHandMeta = const VerificationMeta(
    'quantityOnHand',
  );
  @override
  late final GeneratedColumn<int> quantityOnHand = GeneratedColumn<int>(
    'quantity_on_hand',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reservedQuantityMeta = const VerificationMeta(
    'reservedQuantity',
  );
  @override
  late final GeneratedColumn<int> reservedQuantity = GeneratedColumn<int>(
    'reserved_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastCountedAtMeta = const VerificationMeta(
    'lastCountedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastCountedAt =
      GeneratedColumn<DateTime>(
        'last_counted_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    productId,
    branchId,
    quantityOnHand,
    reservedQuantity,
    lastCountedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(
        _branchIdMeta,
        branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('quantity_on_hand')) {
      context.handle(
        _quantityOnHandMeta,
        quantityOnHand.isAcceptableOrUnknown(
          data['quantity_on_hand']!,
          _quantityOnHandMeta,
        ),
      );
    }
    if (data.containsKey('reserved_quantity')) {
      context.handle(
        _reservedQuantityMeta,
        reservedQuantity.isAcceptableOrUnknown(
          data['reserved_quantity']!,
          _reservedQuantityMeta,
        ),
      );
    }
    if (data.containsKey('last_counted_at')) {
      context.handle(
        _lastCountedAtMeta,
        lastCountedAt.isAcceptableOrUnknown(
          data['last_counted_at']!,
          _lastCountedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      branchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_id'],
      )!,
      quantityOnHand: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_on_hand'],
      )!,
      reservedQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reserved_quantity'],
      )!,
      lastCountedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_counted_at'],
      ),
    );
  }

  @override
  $StockItemsTable createAlias(String alias) {
    return $StockItemsTable(attachedDatabase, alias);
  }
}

class StockItem extends DataClass implements Insertable<StockItem> {
  final String id;
  final String storeId;
  final String productId;
  final String branchId;
  final int quantityOnHand;
  final int reservedQuantity;
  final DateTime? lastCountedAt;
  const StockItem({
    required this.id,
    required this.storeId,
    required this.productId,
    required this.branchId,
    required this.quantityOnHand,
    required this.reservedQuantity,
    this.lastCountedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['product_id'] = Variable<String>(productId);
    map['branch_id'] = Variable<String>(branchId);
    map['quantity_on_hand'] = Variable<int>(quantityOnHand);
    map['reserved_quantity'] = Variable<int>(reservedQuantity);
    if (!nullToAbsent || lastCountedAt != null) {
      map['last_counted_at'] = Variable<DateTime>(lastCountedAt);
    }
    return map;
  }

  StockItemsCompanion toCompanion(bool nullToAbsent) {
    return StockItemsCompanion(
      id: Value(id),
      storeId: Value(storeId),
      productId: Value(productId),
      branchId: Value(branchId),
      quantityOnHand: Value(quantityOnHand),
      reservedQuantity: Value(reservedQuantity),
      lastCountedAt: lastCountedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCountedAt),
    );
  }

  factory StockItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockItem(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      productId: serializer.fromJson<String>(json['productId']),
      branchId: serializer.fromJson<String>(json['branchId']),
      quantityOnHand: serializer.fromJson<int>(json['quantityOnHand']),
      reservedQuantity: serializer.fromJson<int>(json['reservedQuantity']),
      lastCountedAt: serializer.fromJson<DateTime?>(json['lastCountedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'productId': serializer.toJson<String>(productId),
      'branchId': serializer.toJson<String>(branchId),
      'quantityOnHand': serializer.toJson<int>(quantityOnHand),
      'reservedQuantity': serializer.toJson<int>(reservedQuantity),
      'lastCountedAt': serializer.toJson<DateTime?>(lastCountedAt),
    };
  }

  StockItem copyWith({
    String? id,
    String? storeId,
    String? productId,
    String? branchId,
    int? quantityOnHand,
    int? reservedQuantity,
    Value<DateTime?> lastCountedAt = const Value.absent(),
  }) => StockItem(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    productId: productId ?? this.productId,
    branchId: branchId ?? this.branchId,
    quantityOnHand: quantityOnHand ?? this.quantityOnHand,
    reservedQuantity: reservedQuantity ?? this.reservedQuantity,
    lastCountedAt: lastCountedAt.present
        ? lastCountedAt.value
        : this.lastCountedAt,
  );
  StockItem copyWithCompanion(StockItemsCompanion data) {
    return StockItem(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      productId: data.productId.present ? data.productId.value : this.productId,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      quantityOnHand: data.quantityOnHand.present
          ? data.quantityOnHand.value
          : this.quantityOnHand,
      reservedQuantity: data.reservedQuantity.present
          ? data.reservedQuantity.value
          : this.reservedQuantity,
      lastCountedAt: data.lastCountedAt.present
          ? data.lastCountedAt.value
          : this.lastCountedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockItem(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('productId: $productId, ')
          ..write('branchId: $branchId, ')
          ..write('quantityOnHand: $quantityOnHand, ')
          ..write('reservedQuantity: $reservedQuantity, ')
          ..write('lastCountedAt: $lastCountedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    productId,
    branchId,
    quantityOnHand,
    reservedQuantity,
    lastCountedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockItem &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.productId == this.productId &&
          other.branchId == this.branchId &&
          other.quantityOnHand == this.quantityOnHand &&
          other.reservedQuantity == this.reservedQuantity &&
          other.lastCountedAt == this.lastCountedAt);
}

class StockItemsCompanion extends UpdateCompanion<StockItem> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> productId;
  final Value<String> branchId;
  final Value<int> quantityOnHand;
  final Value<int> reservedQuantity;
  final Value<DateTime?> lastCountedAt;
  final Value<int> rowid;
  const StockItemsCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.productId = const Value.absent(),
    this.branchId = const Value.absent(),
    this.quantityOnHand = const Value.absent(),
    this.reservedQuantity = const Value.absent(),
    this.lastCountedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockItemsCompanion.insert({
    required String id,
    required String storeId,
    required String productId,
    required String branchId,
    this.quantityOnHand = const Value.absent(),
    this.reservedQuantity = const Value.absent(),
    this.lastCountedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       productId = Value(productId),
       branchId = Value(branchId);
  static Insertable<StockItem> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? productId,
    Expression<String>? branchId,
    Expression<int>? quantityOnHand,
    Expression<int>? reservedQuantity,
    Expression<DateTime>? lastCountedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (productId != null) 'product_id': productId,
      if (branchId != null) 'branch_id': branchId,
      if (quantityOnHand != null) 'quantity_on_hand': quantityOnHand,
      if (reservedQuantity != null) 'reserved_quantity': reservedQuantity,
      if (lastCountedAt != null) 'last_counted_at': lastCountedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? productId,
    Value<String>? branchId,
    Value<int>? quantityOnHand,
    Value<int>? reservedQuantity,
    Value<DateTime?>? lastCountedAt,
    Value<int>? rowid,
  }) {
    return StockItemsCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      productId: productId ?? this.productId,
      branchId: branchId ?? this.branchId,
      quantityOnHand: quantityOnHand ?? this.quantityOnHand,
      reservedQuantity: reservedQuantity ?? this.reservedQuantity,
      lastCountedAt: lastCountedAt ?? this.lastCountedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (quantityOnHand.present) {
      map['quantity_on_hand'] = Variable<int>(quantityOnHand.value);
    }
    if (reservedQuantity.present) {
      map['reserved_quantity'] = Variable<int>(reservedQuantity.value);
    }
    if (lastCountedAt.present) {
      map['last_counted_at'] = Variable<DateTime>(lastCountedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockItemsCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('productId: $productId, ')
          ..write('branchId: $branchId, ')
          ..write('quantityOnHand: $quantityOnHand, ')
          ..write('reservedQuantity: $reservedQuantity, ')
          ..write('lastCountedAt: $lastCountedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockMovementsTable extends StockMovements
    with TableInfo<$StockMovementsTable, StockMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _branchIdMeta = const VerificationMeta(
    'branchId',
  );
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
    'branch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCostMinorUnitsMeta =
      const VerificationMeta('unitCostMinorUnits');
  @override
  late final GeneratedColumn<int> unitCostMinorUnits = GeneratedColumn<int>(
    'unit_cost_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _referenceTypeMeta = const VerificationMeta(
    'referenceType',
  );
  @override
  late final GeneratedColumn<String> referenceType = GeneratedColumn<String>(
    'reference_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceIdMeta = const VerificationMeta(
    'referenceId',
  );
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
    'reference_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByUserIdMeta = const VerificationMeta(
    'createdByUserId',
  );
  @override
  late final GeneratedColumn<String> createdByUserId = GeneratedColumn<String>(
    'created_by_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    productId,
    branchId,
    type,
    quantity,
    unitCostMinorUnits,
    referenceType,
    referenceId,
    createdByUserId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockMovement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(
        _branchIdMeta,
        branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_cost_minor_units')) {
      context.handle(
        _unitCostMinorUnitsMeta,
        unitCostMinorUnits.isAcceptableOrUnknown(
          data['unit_cost_minor_units']!,
          _unitCostMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('reference_type')) {
      context.handle(
        _referenceTypeMeta,
        referenceType.isAcceptableOrUnknown(
          data['reference_type']!,
          _referenceTypeMeta,
        ),
      );
    }
    if (data.containsKey('reference_id')) {
      context.handle(
        _referenceIdMeta,
        referenceId.isAcceptableOrUnknown(
          data['reference_id']!,
          _referenceIdMeta,
        ),
      );
    }
    if (data.containsKey('created_by_user_id')) {
      context.handle(
        _createdByUserIdMeta,
        createdByUserId.isAcceptableOrUnknown(
          data['created_by_user_id']!,
          _createdByUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdByUserIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockMovement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      branchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      unitCostMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_cost_minor_units'],
      )!,
      referenceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_type'],
      ),
      referenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_id'],
      ),
      createdByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StockMovementsTable createAlias(String alias) {
    return $StockMovementsTable(attachedDatabase, alias);
  }
}

class StockMovement extends DataClass implements Insertable<StockMovement> {
  final String id;
  final String storeId;
  final String productId;
  final String branchId;
  final String type;
  final int quantity;
  final int unitCostMinorUnits;
  final String? referenceType;
  final String? referenceId;
  final String createdByUserId;
  final DateTime createdAt;
  const StockMovement({
    required this.id,
    required this.storeId,
    required this.productId,
    required this.branchId,
    required this.type,
    required this.quantity,
    required this.unitCostMinorUnits,
    this.referenceType,
    this.referenceId,
    required this.createdByUserId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['product_id'] = Variable<String>(productId);
    map['branch_id'] = Variable<String>(branchId);
    map['type'] = Variable<String>(type);
    map['quantity'] = Variable<int>(quantity);
    map['unit_cost_minor_units'] = Variable<int>(unitCostMinorUnits);
    if (!nullToAbsent || referenceType != null) {
      map['reference_type'] = Variable<String>(referenceType);
    }
    if (!nullToAbsent || referenceId != null) {
      map['reference_id'] = Variable<String>(referenceId);
    }
    map['created_by_user_id'] = Variable<String>(createdByUserId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StockMovementsCompanion toCompanion(bool nullToAbsent) {
    return StockMovementsCompanion(
      id: Value(id),
      storeId: Value(storeId),
      productId: Value(productId),
      branchId: Value(branchId),
      type: Value(type),
      quantity: Value(quantity),
      unitCostMinorUnits: Value(unitCostMinorUnits),
      referenceType: referenceType == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceType),
      referenceId: referenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceId),
      createdByUserId: Value(createdByUserId),
      createdAt: Value(createdAt),
    );
  }

  factory StockMovement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockMovement(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      productId: serializer.fromJson<String>(json['productId']),
      branchId: serializer.fromJson<String>(json['branchId']),
      type: serializer.fromJson<String>(json['type']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitCostMinorUnits: serializer.fromJson<int>(json['unitCostMinorUnits']),
      referenceType: serializer.fromJson<String?>(json['referenceType']),
      referenceId: serializer.fromJson<String?>(json['referenceId']),
      createdByUserId: serializer.fromJson<String>(json['createdByUserId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'productId': serializer.toJson<String>(productId),
      'branchId': serializer.toJson<String>(branchId),
      'type': serializer.toJson<String>(type),
      'quantity': serializer.toJson<int>(quantity),
      'unitCostMinorUnits': serializer.toJson<int>(unitCostMinorUnits),
      'referenceType': serializer.toJson<String?>(referenceType),
      'referenceId': serializer.toJson<String?>(referenceId),
      'createdByUserId': serializer.toJson<String>(createdByUserId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StockMovement copyWith({
    String? id,
    String? storeId,
    String? productId,
    String? branchId,
    String? type,
    int? quantity,
    int? unitCostMinorUnits,
    Value<String?> referenceType = const Value.absent(),
    Value<String?> referenceId = const Value.absent(),
    String? createdByUserId,
    DateTime? createdAt,
  }) => StockMovement(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    productId: productId ?? this.productId,
    branchId: branchId ?? this.branchId,
    type: type ?? this.type,
    quantity: quantity ?? this.quantity,
    unitCostMinorUnits: unitCostMinorUnits ?? this.unitCostMinorUnits,
    referenceType: referenceType.present
        ? referenceType.value
        : this.referenceType,
    referenceId: referenceId.present ? referenceId.value : this.referenceId,
    createdByUserId: createdByUserId ?? this.createdByUserId,
    createdAt: createdAt ?? this.createdAt,
  );
  StockMovement copyWithCompanion(StockMovementsCompanion data) {
    return StockMovement(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      productId: data.productId.present ? data.productId.value : this.productId,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      type: data.type.present ? data.type.value : this.type,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitCostMinorUnits: data.unitCostMinorUnits.present
          ? data.unitCostMinorUnits.value
          : this.unitCostMinorUnits,
      referenceType: data.referenceType.present
          ? data.referenceType.value
          : this.referenceType,
      referenceId: data.referenceId.present
          ? data.referenceId.value
          : this.referenceId,
      createdByUserId: data.createdByUserId.present
          ? data.createdByUserId.value
          : this.createdByUserId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockMovement(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('productId: $productId, ')
          ..write('branchId: $branchId, ')
          ..write('type: $type, ')
          ..write('quantity: $quantity, ')
          ..write('unitCostMinorUnits: $unitCostMinorUnits, ')
          ..write('referenceType: $referenceType, ')
          ..write('referenceId: $referenceId, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    productId,
    branchId,
    type,
    quantity,
    unitCostMinorUnits,
    referenceType,
    referenceId,
    createdByUserId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockMovement &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.productId == this.productId &&
          other.branchId == this.branchId &&
          other.type == this.type &&
          other.quantity == this.quantity &&
          other.unitCostMinorUnits == this.unitCostMinorUnits &&
          other.referenceType == this.referenceType &&
          other.referenceId == this.referenceId &&
          other.createdByUserId == this.createdByUserId &&
          other.createdAt == this.createdAt);
}

class StockMovementsCompanion extends UpdateCompanion<StockMovement> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> productId;
  final Value<String> branchId;
  final Value<String> type;
  final Value<int> quantity;
  final Value<int> unitCostMinorUnits;
  final Value<String?> referenceType;
  final Value<String?> referenceId;
  final Value<String> createdByUserId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StockMovementsCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.productId = const Value.absent(),
    this.branchId = const Value.absent(),
    this.type = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitCostMinorUnits = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.createdByUserId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockMovementsCompanion.insert({
    required String id,
    required String storeId,
    required String productId,
    required String branchId,
    required String type,
    required int quantity,
    this.unitCostMinorUnits = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.referenceId = const Value.absent(),
    required String createdByUserId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       productId = Value(productId),
       branchId = Value(branchId),
       type = Value(type),
       quantity = Value(quantity),
       createdByUserId = Value(createdByUserId),
       createdAt = Value(createdAt);
  static Insertable<StockMovement> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? productId,
    Expression<String>? branchId,
    Expression<String>? type,
    Expression<int>? quantity,
    Expression<int>? unitCostMinorUnits,
    Expression<String>? referenceType,
    Expression<String>? referenceId,
    Expression<String>? createdByUserId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (productId != null) 'product_id': productId,
      if (branchId != null) 'branch_id': branchId,
      if (type != null) 'type': type,
      if (quantity != null) 'quantity': quantity,
      if (unitCostMinorUnits != null)
        'unit_cost_minor_units': unitCostMinorUnits,
      if (referenceType != null) 'reference_type': referenceType,
      if (referenceId != null) 'reference_id': referenceId,
      if (createdByUserId != null) 'created_by_user_id': createdByUserId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockMovementsCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? productId,
    Value<String>? branchId,
    Value<String>? type,
    Value<int>? quantity,
    Value<int>? unitCostMinorUnits,
    Value<String?>? referenceType,
    Value<String?>? referenceId,
    Value<String>? createdByUserId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return StockMovementsCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      productId: productId ?? this.productId,
      branchId: branchId ?? this.branchId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      unitCostMinorUnits: unitCostMinorUnits ?? this.unitCostMinorUnits,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitCostMinorUnits.present) {
      map['unit_cost_minor_units'] = Variable<int>(unitCostMinorUnits.value);
    }
    if (referenceType.present) {
      map['reference_type'] = Variable<String>(referenceType.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (createdByUserId.present) {
      map['created_by_user_id'] = Variable<String>(createdByUserId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('productId: $productId, ')
          ..write('branchId: $branchId, ')
          ..write('type: $type, ')
          ..write('quantity: $quantity, ')
          ..write('unitCostMinorUnits: $unitCostMinorUnits, ')
          ..write('referenceType: $referenceType, ')
          ..write('referenceId: $referenceId, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockTransfersTable extends StockTransfers
    with TableInfo<$StockTransfersTable, StockTransfer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockTransfersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromBranchIdMeta = const VerificationMeta(
    'fromBranchId',
  );
  @override
  late final GeneratedColumn<String> fromBranchId = GeneratedColumn<String>(
    'from_branch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toBranchIdMeta = const VerificationMeta(
    'toBranchId',
  );
  @override
  late final GeneratedColumn<String> toBranchId = GeneratedColumn<String>(
    'to_branch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _requestedByUserIdMeta = const VerificationMeta(
    'requestedByUserId',
  );
  @override
  late final GeneratedColumn<String> requestedByUserId =
      GeneratedColumn<String>(
        'requested_by_user_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _receivedByUserIdMeta = const VerificationMeta(
    'receivedByUserId',
  );
  @override
  late final GeneratedColumn<String> receivedByUserId = GeneratedColumn<String>(
    'received_by_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    fromBranchId,
    toBranchId,
    status,
    requestedByUserId,
    receivedByUserId,
    createdAt,
    receivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_transfers';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockTransfer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('from_branch_id')) {
      context.handle(
        _fromBranchIdMeta,
        fromBranchId.isAcceptableOrUnknown(
          data['from_branch_id']!,
          _fromBranchIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromBranchIdMeta);
    }
    if (data.containsKey('to_branch_id')) {
      context.handle(
        _toBranchIdMeta,
        toBranchId.isAcceptableOrUnknown(
          data['to_branch_id']!,
          _toBranchIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_toBranchIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('requested_by_user_id')) {
      context.handle(
        _requestedByUserIdMeta,
        requestedByUserId.isAcceptableOrUnknown(
          data['requested_by_user_id']!,
          _requestedByUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestedByUserIdMeta);
    }
    if (data.containsKey('received_by_user_id')) {
      context.handle(
        _receivedByUserIdMeta,
        receivedByUserId.isAcceptableOrUnknown(
          data['received_by_user_id']!,
          _receivedByUserIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockTransfer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockTransfer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      fromBranchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_branch_id'],
      )!,
      toBranchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_branch_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      requestedByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requested_by_user_id'],
      )!,
      receivedByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}received_by_user_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      ),
    );
  }

  @override
  $StockTransfersTable createAlias(String alias) {
    return $StockTransfersTable(attachedDatabase, alias);
  }
}

class StockTransfer extends DataClass implements Insertable<StockTransfer> {
  final String id;
  final String storeId;
  final String fromBranchId;
  final String toBranchId;
  final String status;
  final String requestedByUserId;
  final String? receivedByUserId;
  final DateTime createdAt;
  final DateTime? receivedAt;
  const StockTransfer({
    required this.id,
    required this.storeId,
    required this.fromBranchId,
    required this.toBranchId,
    required this.status,
    required this.requestedByUserId,
    this.receivedByUserId,
    required this.createdAt,
    this.receivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['from_branch_id'] = Variable<String>(fromBranchId);
    map['to_branch_id'] = Variable<String>(toBranchId);
    map['status'] = Variable<String>(status);
    map['requested_by_user_id'] = Variable<String>(requestedByUserId);
    if (!nullToAbsent || receivedByUserId != null) {
      map['received_by_user_id'] = Variable<String>(receivedByUserId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || receivedAt != null) {
      map['received_at'] = Variable<DateTime>(receivedAt);
    }
    return map;
  }

  StockTransfersCompanion toCompanion(bool nullToAbsent) {
    return StockTransfersCompanion(
      id: Value(id),
      storeId: Value(storeId),
      fromBranchId: Value(fromBranchId),
      toBranchId: Value(toBranchId),
      status: Value(status),
      requestedByUserId: Value(requestedByUserId),
      receivedByUserId: receivedByUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedByUserId),
      createdAt: Value(createdAt),
      receivedAt: receivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedAt),
    );
  }

  factory StockTransfer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockTransfer(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      fromBranchId: serializer.fromJson<String>(json['fromBranchId']),
      toBranchId: serializer.fromJson<String>(json['toBranchId']),
      status: serializer.fromJson<String>(json['status']),
      requestedByUserId: serializer.fromJson<String>(json['requestedByUserId']),
      receivedByUserId: serializer.fromJson<String?>(json['receivedByUserId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      receivedAt: serializer.fromJson<DateTime?>(json['receivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'fromBranchId': serializer.toJson<String>(fromBranchId),
      'toBranchId': serializer.toJson<String>(toBranchId),
      'status': serializer.toJson<String>(status),
      'requestedByUserId': serializer.toJson<String>(requestedByUserId),
      'receivedByUserId': serializer.toJson<String?>(receivedByUserId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'receivedAt': serializer.toJson<DateTime?>(receivedAt),
    };
  }

  StockTransfer copyWith({
    String? id,
    String? storeId,
    String? fromBranchId,
    String? toBranchId,
    String? status,
    String? requestedByUserId,
    Value<String?> receivedByUserId = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> receivedAt = const Value.absent(),
  }) => StockTransfer(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    fromBranchId: fromBranchId ?? this.fromBranchId,
    toBranchId: toBranchId ?? this.toBranchId,
    status: status ?? this.status,
    requestedByUserId: requestedByUserId ?? this.requestedByUserId,
    receivedByUserId: receivedByUserId.present
        ? receivedByUserId.value
        : this.receivedByUserId,
    createdAt: createdAt ?? this.createdAt,
    receivedAt: receivedAt.present ? receivedAt.value : this.receivedAt,
  );
  StockTransfer copyWithCompanion(StockTransfersCompanion data) {
    return StockTransfer(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      fromBranchId: data.fromBranchId.present
          ? data.fromBranchId.value
          : this.fromBranchId,
      toBranchId: data.toBranchId.present
          ? data.toBranchId.value
          : this.toBranchId,
      status: data.status.present ? data.status.value : this.status,
      requestedByUserId: data.requestedByUserId.present
          ? data.requestedByUserId.value
          : this.requestedByUserId,
      receivedByUserId: data.receivedByUserId.present
          ? data.receivedByUserId.value
          : this.receivedByUserId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockTransfer(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('fromBranchId: $fromBranchId, ')
          ..write('toBranchId: $toBranchId, ')
          ..write('status: $status, ')
          ..write('requestedByUserId: $requestedByUserId, ')
          ..write('receivedByUserId: $receivedByUserId, ')
          ..write('createdAt: $createdAt, ')
          ..write('receivedAt: $receivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    fromBranchId,
    toBranchId,
    status,
    requestedByUserId,
    receivedByUserId,
    createdAt,
    receivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockTransfer &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.fromBranchId == this.fromBranchId &&
          other.toBranchId == this.toBranchId &&
          other.status == this.status &&
          other.requestedByUserId == this.requestedByUserId &&
          other.receivedByUserId == this.receivedByUserId &&
          other.createdAt == this.createdAt &&
          other.receivedAt == this.receivedAt);
}

class StockTransfersCompanion extends UpdateCompanion<StockTransfer> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> fromBranchId;
  final Value<String> toBranchId;
  final Value<String> status;
  final Value<String> requestedByUserId;
  final Value<String?> receivedByUserId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> receivedAt;
  final Value<int> rowid;
  const StockTransfersCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.fromBranchId = const Value.absent(),
    this.toBranchId = const Value.absent(),
    this.status = const Value.absent(),
    this.requestedByUserId = const Value.absent(),
    this.receivedByUserId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockTransfersCompanion.insert({
    required String id,
    required String storeId,
    required String fromBranchId,
    required String toBranchId,
    this.status = const Value.absent(),
    required String requestedByUserId,
    this.receivedByUserId = const Value.absent(),
    required DateTime createdAt,
    this.receivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       fromBranchId = Value(fromBranchId),
       toBranchId = Value(toBranchId),
       requestedByUserId = Value(requestedByUserId),
       createdAt = Value(createdAt);
  static Insertable<StockTransfer> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? fromBranchId,
    Expression<String>? toBranchId,
    Expression<String>? status,
    Expression<String>? requestedByUserId,
    Expression<String>? receivedByUserId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? receivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (fromBranchId != null) 'from_branch_id': fromBranchId,
      if (toBranchId != null) 'to_branch_id': toBranchId,
      if (status != null) 'status': status,
      if (requestedByUserId != null) 'requested_by_user_id': requestedByUserId,
      if (receivedByUserId != null) 'received_by_user_id': receivedByUserId,
      if (createdAt != null) 'created_at': createdAt,
      if (receivedAt != null) 'received_at': receivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockTransfersCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? fromBranchId,
    Value<String>? toBranchId,
    Value<String>? status,
    Value<String>? requestedByUserId,
    Value<String?>? receivedByUserId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? receivedAt,
    Value<int>? rowid,
  }) {
    return StockTransfersCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      fromBranchId: fromBranchId ?? this.fromBranchId,
      toBranchId: toBranchId ?? this.toBranchId,
      status: status ?? this.status,
      requestedByUserId: requestedByUserId ?? this.requestedByUserId,
      receivedByUserId: receivedByUserId ?? this.receivedByUserId,
      createdAt: createdAt ?? this.createdAt,
      receivedAt: receivedAt ?? this.receivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (fromBranchId.present) {
      map['from_branch_id'] = Variable<String>(fromBranchId.value);
    }
    if (toBranchId.present) {
      map['to_branch_id'] = Variable<String>(toBranchId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (requestedByUserId.present) {
      map['requested_by_user_id'] = Variable<String>(requestedByUserId.value);
    }
    if (receivedByUserId.present) {
      map['received_by_user_id'] = Variable<String>(receivedByUserId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockTransfersCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('fromBranchId: $fromBranchId, ')
          ..write('toBranchId: $toBranchId, ')
          ..write('status: $status, ')
          ..write('requestedByUserId: $requestedByUserId, ')
          ..write('receivedByUserId: $receivedByUserId, ')
          ..write('createdAt: $createdAt, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockTransferLinesTable extends StockTransferLines
    with TableInfo<$StockTransferLinesTable, StockTransferLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockTransferLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockTransferIdMeta = const VerificationMeta(
    'stockTransferId',
  );
  @override
  late final GeneratedColumn<String> stockTransferId = GeneratedColumn<String>(
    'stock_transfer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    stockTransferId,
    productId,
    quantity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_transfer_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockTransferLine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('stock_transfer_id')) {
      context.handle(
        _stockTransferIdMeta,
        stockTransferId.isAcceptableOrUnknown(
          data['stock_transfer_id']!,
          _stockTransferIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stockTransferIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockTransferLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockTransferLine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      stockTransferId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stock_transfer_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
    );
  }

  @override
  $StockTransferLinesTable createAlias(String alias) {
    return $StockTransferLinesTable(attachedDatabase, alias);
  }
}

class StockTransferLine extends DataClass
    implements Insertable<StockTransferLine> {
  final String id;
  final String stockTransferId;
  final String productId;
  final int quantity;
  const StockTransferLine({
    required this.id,
    required this.stockTransferId,
    required this.productId,
    required this.quantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['stock_transfer_id'] = Variable<String>(stockTransferId);
    map['product_id'] = Variable<String>(productId);
    map['quantity'] = Variable<int>(quantity);
    return map;
  }

  StockTransferLinesCompanion toCompanion(bool nullToAbsent) {
    return StockTransferLinesCompanion(
      id: Value(id),
      stockTransferId: Value(stockTransferId),
      productId: Value(productId),
      quantity: Value(quantity),
    );
  }

  factory StockTransferLine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockTransferLine(
      id: serializer.fromJson<String>(json['id']),
      stockTransferId: serializer.fromJson<String>(json['stockTransferId']),
      productId: serializer.fromJson<String>(json['productId']),
      quantity: serializer.fromJson<int>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'stockTransferId': serializer.toJson<String>(stockTransferId),
      'productId': serializer.toJson<String>(productId),
      'quantity': serializer.toJson<int>(quantity),
    };
  }

  StockTransferLine copyWith({
    String? id,
    String? stockTransferId,
    String? productId,
    int? quantity,
  }) => StockTransferLine(
    id: id ?? this.id,
    stockTransferId: stockTransferId ?? this.stockTransferId,
    productId: productId ?? this.productId,
    quantity: quantity ?? this.quantity,
  );
  StockTransferLine copyWithCompanion(StockTransferLinesCompanion data) {
    return StockTransferLine(
      id: data.id.present ? data.id.value : this.id,
      stockTransferId: data.stockTransferId.present
          ? data.stockTransferId.value
          : this.stockTransferId,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockTransferLine(')
          ..write('id: $id, ')
          ..write('stockTransferId: $stockTransferId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, stockTransferId, productId, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockTransferLine &&
          other.id == this.id &&
          other.stockTransferId == this.stockTransferId &&
          other.productId == this.productId &&
          other.quantity == this.quantity);
}

class StockTransferLinesCompanion extends UpdateCompanion<StockTransferLine> {
  final Value<String> id;
  final Value<String> stockTransferId;
  final Value<String> productId;
  final Value<int> quantity;
  final Value<int> rowid;
  const StockTransferLinesCompanion({
    this.id = const Value.absent(),
    this.stockTransferId = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockTransferLinesCompanion.insert({
    required String id,
    required String stockTransferId,
    required String productId,
    required int quantity,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       stockTransferId = Value(stockTransferId),
       productId = Value(productId),
       quantity = Value(quantity);
  static Insertable<StockTransferLine> custom({
    Expression<String>? id,
    Expression<String>? stockTransferId,
    Expression<String>? productId,
    Expression<int>? quantity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (stockTransferId != null) 'stock_transfer_id': stockTransferId,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockTransferLinesCompanion copyWith({
    Value<String>? id,
    Value<String>? stockTransferId,
    Value<String>? productId,
    Value<int>? quantity,
    Value<int>? rowid,
  }) {
    return StockTransferLinesCompanion(
      id: id ?? this.id,
      stockTransferId: stockTransferId ?? this.stockTransferId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (stockTransferId.present) {
      map['stock_transfer_id'] = Variable<String>(stockTransferId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockTransferLinesCompanion(')
          ..write('id: $id, ')
          ..write('stockTransferId: $stockTransferId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseOrdersTable extends PurchaseOrders
    with TableInfo<$PurchaseOrdersTable, PurchaseOrder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _branchIdMeta = const VerificationMeta(
    'branchId',
  );
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
    'branch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _orderDateMeta = const VerificationMeta(
    'orderDate',
  );
  @override
  late final GeneratedColumn<DateTime> orderDate = GeneratedColumn<DateTime>(
    'order_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedDateMeta = const VerificationMeta(
    'expectedDate',
  );
  @override
  late final GeneratedColumn<DateTime> expectedDate = GeneratedColumn<DateTime>(
    'expected_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalCostMinorUnitsMeta =
      const VerificationMeta('totalCostMinorUnits');
  @override
  late final GeneratedColumn<int> totalCostMinorUnits = GeneratedColumn<int>(
    'total_cost_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _paidImmediatelyMeta = const VerificationMeta(
    'paidImmediately',
  );
  @override
  late final GeneratedColumn<bool> paidImmediately = GeneratedColumn<bool>(
    'paid_immediately',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("paid_immediately" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    branchId,
    supplierId,
    status,
    orderDate,
    expectedDate,
    totalCostMinorUnits,
    paidImmediately,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseOrder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(
        _branchIdMeta,
        branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_supplierIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('order_date')) {
      context.handle(
        _orderDateMeta,
        orderDate.isAcceptableOrUnknown(data['order_date']!, _orderDateMeta),
      );
    } else if (isInserting) {
      context.missing(_orderDateMeta);
    }
    if (data.containsKey('expected_date')) {
      context.handle(
        _expectedDateMeta,
        expectedDate.isAcceptableOrUnknown(
          data['expected_date']!,
          _expectedDateMeta,
        ),
      );
    }
    if (data.containsKey('total_cost_minor_units')) {
      context.handle(
        _totalCostMinorUnitsMeta,
        totalCostMinorUnits.isAcceptableOrUnknown(
          data['total_cost_minor_units']!,
          _totalCostMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('paid_immediately')) {
      context.handle(
        _paidImmediatelyMeta,
        paidImmediately.isAcceptableOrUnknown(
          data['paid_immediately']!,
          _paidImmediatelyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseOrder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseOrder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      branchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_id'],
      )!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      orderDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}order_date'],
      )!,
      expectedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expected_date'],
      ),
      totalCostMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cost_minor_units'],
      )!,
      paidImmediately: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}paid_immediately'],
      )!,
    );
  }

  @override
  $PurchaseOrdersTable createAlias(String alias) {
    return $PurchaseOrdersTable(attachedDatabase, alias);
  }
}

class PurchaseOrder extends DataClass implements Insertable<PurchaseOrder> {
  final String id;
  final String storeId;
  final String branchId;
  final String supplierId;
  final String status;
  final DateTime orderDate;
  final DateTime? expectedDate;
  final int totalCostMinorUnits;
  final bool paidImmediately;
  const PurchaseOrder({
    required this.id,
    required this.storeId,
    required this.branchId,
    required this.supplierId,
    required this.status,
    required this.orderDate,
    this.expectedDate,
    required this.totalCostMinorUnits,
    required this.paidImmediately,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['branch_id'] = Variable<String>(branchId);
    map['supplier_id'] = Variable<String>(supplierId);
    map['status'] = Variable<String>(status);
    map['order_date'] = Variable<DateTime>(orderDate);
    if (!nullToAbsent || expectedDate != null) {
      map['expected_date'] = Variable<DateTime>(expectedDate);
    }
    map['total_cost_minor_units'] = Variable<int>(totalCostMinorUnits);
    map['paid_immediately'] = Variable<bool>(paidImmediately);
    return map;
  }

  PurchaseOrdersCompanion toCompanion(bool nullToAbsent) {
    return PurchaseOrdersCompanion(
      id: Value(id),
      storeId: Value(storeId),
      branchId: Value(branchId),
      supplierId: Value(supplierId),
      status: Value(status),
      orderDate: Value(orderDate),
      expectedDate: expectedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedDate),
      totalCostMinorUnits: Value(totalCostMinorUnits),
      paidImmediately: Value(paidImmediately),
    );
  }

  factory PurchaseOrder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseOrder(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      branchId: serializer.fromJson<String>(json['branchId']),
      supplierId: serializer.fromJson<String>(json['supplierId']),
      status: serializer.fromJson<String>(json['status']),
      orderDate: serializer.fromJson<DateTime>(json['orderDate']),
      expectedDate: serializer.fromJson<DateTime?>(json['expectedDate']),
      totalCostMinorUnits: serializer.fromJson<int>(
        json['totalCostMinorUnits'],
      ),
      paidImmediately: serializer.fromJson<bool>(json['paidImmediately']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'branchId': serializer.toJson<String>(branchId),
      'supplierId': serializer.toJson<String>(supplierId),
      'status': serializer.toJson<String>(status),
      'orderDate': serializer.toJson<DateTime>(orderDate),
      'expectedDate': serializer.toJson<DateTime?>(expectedDate),
      'totalCostMinorUnits': serializer.toJson<int>(totalCostMinorUnits),
      'paidImmediately': serializer.toJson<bool>(paidImmediately),
    };
  }

  PurchaseOrder copyWith({
    String? id,
    String? storeId,
    String? branchId,
    String? supplierId,
    String? status,
    DateTime? orderDate,
    Value<DateTime?> expectedDate = const Value.absent(),
    int? totalCostMinorUnits,
    bool? paidImmediately,
  }) => PurchaseOrder(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    branchId: branchId ?? this.branchId,
    supplierId: supplierId ?? this.supplierId,
    status: status ?? this.status,
    orderDate: orderDate ?? this.orderDate,
    expectedDate: expectedDate.present ? expectedDate.value : this.expectedDate,
    totalCostMinorUnits: totalCostMinorUnits ?? this.totalCostMinorUnits,
    paidImmediately: paidImmediately ?? this.paidImmediately,
  );
  PurchaseOrder copyWithCompanion(PurchaseOrdersCompanion data) {
    return PurchaseOrder(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      status: data.status.present ? data.status.value : this.status,
      orderDate: data.orderDate.present ? data.orderDate.value : this.orderDate,
      expectedDate: data.expectedDate.present
          ? data.expectedDate.value
          : this.expectedDate,
      totalCostMinorUnits: data.totalCostMinorUnits.present
          ? data.totalCostMinorUnits.value
          : this.totalCostMinorUnits,
      paidImmediately: data.paidImmediately.present
          ? data.paidImmediately.value
          : this.paidImmediately,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseOrder(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('branchId: $branchId, ')
          ..write('supplierId: $supplierId, ')
          ..write('status: $status, ')
          ..write('orderDate: $orderDate, ')
          ..write('expectedDate: $expectedDate, ')
          ..write('totalCostMinorUnits: $totalCostMinorUnits, ')
          ..write('paidImmediately: $paidImmediately')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    branchId,
    supplierId,
    status,
    orderDate,
    expectedDate,
    totalCostMinorUnits,
    paidImmediately,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseOrder &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.branchId == this.branchId &&
          other.supplierId == this.supplierId &&
          other.status == this.status &&
          other.orderDate == this.orderDate &&
          other.expectedDate == this.expectedDate &&
          other.totalCostMinorUnits == this.totalCostMinorUnits &&
          other.paidImmediately == this.paidImmediately);
}

class PurchaseOrdersCompanion extends UpdateCompanion<PurchaseOrder> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> branchId;
  final Value<String> supplierId;
  final Value<String> status;
  final Value<DateTime> orderDate;
  final Value<DateTime?> expectedDate;
  final Value<int> totalCostMinorUnits;
  final Value<bool> paidImmediately;
  final Value<int> rowid;
  const PurchaseOrdersCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.branchId = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.status = const Value.absent(),
    this.orderDate = const Value.absent(),
    this.expectedDate = const Value.absent(),
    this.totalCostMinorUnits = const Value.absent(),
    this.paidImmediately = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseOrdersCompanion.insert({
    required String id,
    required String storeId,
    required String branchId,
    required String supplierId,
    this.status = const Value.absent(),
    required DateTime orderDate,
    this.expectedDate = const Value.absent(),
    this.totalCostMinorUnits = const Value.absent(),
    this.paidImmediately = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       branchId = Value(branchId),
       supplierId = Value(supplierId),
       orderDate = Value(orderDate);
  static Insertable<PurchaseOrder> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? branchId,
    Expression<String>? supplierId,
    Expression<String>? status,
    Expression<DateTime>? orderDate,
    Expression<DateTime>? expectedDate,
    Expression<int>? totalCostMinorUnits,
    Expression<bool>? paidImmediately,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (branchId != null) 'branch_id': branchId,
      if (supplierId != null) 'supplier_id': supplierId,
      if (status != null) 'status': status,
      if (orderDate != null) 'order_date': orderDate,
      if (expectedDate != null) 'expected_date': expectedDate,
      if (totalCostMinorUnits != null)
        'total_cost_minor_units': totalCostMinorUnits,
      if (paidImmediately != null) 'paid_immediately': paidImmediately,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseOrdersCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? branchId,
    Value<String>? supplierId,
    Value<String>? status,
    Value<DateTime>? orderDate,
    Value<DateTime?>? expectedDate,
    Value<int>? totalCostMinorUnits,
    Value<bool>? paidImmediately,
    Value<int>? rowid,
  }) {
    return PurchaseOrdersCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      branchId: branchId ?? this.branchId,
      supplierId: supplierId ?? this.supplierId,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      expectedDate: expectedDate ?? this.expectedDate,
      totalCostMinorUnits: totalCostMinorUnits ?? this.totalCostMinorUnits,
      paidImmediately: paidImmediately ?? this.paidImmediately,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (orderDate.present) {
      map['order_date'] = Variable<DateTime>(orderDate.value);
    }
    if (expectedDate.present) {
      map['expected_date'] = Variable<DateTime>(expectedDate.value);
    }
    if (totalCostMinorUnits.present) {
      map['total_cost_minor_units'] = Variable<int>(totalCostMinorUnits.value);
    }
    if (paidImmediately.present) {
      map['paid_immediately'] = Variable<bool>(paidImmediately.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseOrdersCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('branchId: $branchId, ')
          ..write('supplierId: $supplierId, ')
          ..write('status: $status, ')
          ..write('orderDate: $orderDate, ')
          ..write('expectedDate: $expectedDate, ')
          ..write('totalCostMinorUnits: $totalCostMinorUnits, ')
          ..write('paidImmediately: $paidImmediately, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseOrderLinesTable extends PurchaseOrderLines
    with TableInfo<$PurchaseOrderLinesTable, PurchaseOrderLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseOrderLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchaseOrderIdMeta = const VerificationMeta(
    'purchaseOrderId',
  );
  @override
  late final GeneratedColumn<String> purchaseOrderId = GeneratedColumn<String>(
    'purchase_order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityOrderedMeta = const VerificationMeta(
    'quantityOrdered',
  );
  @override
  late final GeneratedColumn<int> quantityOrdered = GeneratedColumn<int>(
    'quantity_ordered',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityReceivedMeta = const VerificationMeta(
    'quantityReceived',
  );
  @override
  late final GeneratedColumn<int> quantityReceived = GeneratedColumn<int>(
    'quantity_received',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _unitCostMinorUnitsMeta =
      const VerificationMeta('unitCostMinorUnits');
  @override
  late final GeneratedColumn<int> unitCostMinorUnits = GeneratedColumn<int>(
    'unit_cost_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    purchaseOrderId,
    productId,
    quantityOrdered,
    quantityReceived,
    unitCostMinorUnits,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_order_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseOrderLine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('purchase_order_id')) {
      context.handle(
        _purchaseOrderIdMeta,
        purchaseOrderId.isAcceptableOrUnknown(
          data['purchase_order_id']!,
          _purchaseOrderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchaseOrderIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity_ordered')) {
      context.handle(
        _quantityOrderedMeta,
        quantityOrdered.isAcceptableOrUnknown(
          data['quantity_ordered']!,
          _quantityOrderedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityOrderedMeta);
    }
    if (data.containsKey('quantity_received')) {
      context.handle(
        _quantityReceivedMeta,
        quantityReceived.isAcceptableOrUnknown(
          data['quantity_received']!,
          _quantityReceivedMeta,
        ),
      );
    }
    if (data.containsKey('unit_cost_minor_units')) {
      context.handle(
        _unitCostMinorUnitsMeta,
        unitCostMinorUnits.isAcceptableOrUnknown(
          data['unit_cost_minor_units']!,
          _unitCostMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitCostMinorUnitsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseOrderLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseOrderLine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      purchaseOrderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_order_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      quantityOrdered: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_ordered'],
      )!,
      quantityReceived: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_received'],
      )!,
      unitCostMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_cost_minor_units'],
      )!,
    );
  }

  @override
  $PurchaseOrderLinesTable createAlias(String alias) {
    return $PurchaseOrderLinesTable(attachedDatabase, alias);
  }
}

class PurchaseOrderLine extends DataClass
    implements Insertable<PurchaseOrderLine> {
  final String id;
  final String purchaseOrderId;
  final String productId;
  final int quantityOrdered;
  final int quantityReceived;
  final int unitCostMinorUnits;
  const PurchaseOrderLine({
    required this.id,
    required this.purchaseOrderId,
    required this.productId,
    required this.quantityOrdered,
    required this.quantityReceived,
    required this.unitCostMinorUnits,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['purchase_order_id'] = Variable<String>(purchaseOrderId);
    map['product_id'] = Variable<String>(productId);
    map['quantity_ordered'] = Variable<int>(quantityOrdered);
    map['quantity_received'] = Variable<int>(quantityReceived);
    map['unit_cost_minor_units'] = Variable<int>(unitCostMinorUnits);
    return map;
  }

  PurchaseOrderLinesCompanion toCompanion(bool nullToAbsent) {
    return PurchaseOrderLinesCompanion(
      id: Value(id),
      purchaseOrderId: Value(purchaseOrderId),
      productId: Value(productId),
      quantityOrdered: Value(quantityOrdered),
      quantityReceived: Value(quantityReceived),
      unitCostMinorUnits: Value(unitCostMinorUnits),
    );
  }

  factory PurchaseOrderLine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseOrderLine(
      id: serializer.fromJson<String>(json['id']),
      purchaseOrderId: serializer.fromJson<String>(json['purchaseOrderId']),
      productId: serializer.fromJson<String>(json['productId']),
      quantityOrdered: serializer.fromJson<int>(json['quantityOrdered']),
      quantityReceived: serializer.fromJson<int>(json['quantityReceived']),
      unitCostMinorUnits: serializer.fromJson<int>(json['unitCostMinorUnits']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'purchaseOrderId': serializer.toJson<String>(purchaseOrderId),
      'productId': serializer.toJson<String>(productId),
      'quantityOrdered': serializer.toJson<int>(quantityOrdered),
      'quantityReceived': serializer.toJson<int>(quantityReceived),
      'unitCostMinorUnits': serializer.toJson<int>(unitCostMinorUnits),
    };
  }

  PurchaseOrderLine copyWith({
    String? id,
    String? purchaseOrderId,
    String? productId,
    int? quantityOrdered,
    int? quantityReceived,
    int? unitCostMinorUnits,
  }) => PurchaseOrderLine(
    id: id ?? this.id,
    purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
    productId: productId ?? this.productId,
    quantityOrdered: quantityOrdered ?? this.quantityOrdered,
    quantityReceived: quantityReceived ?? this.quantityReceived,
    unitCostMinorUnits: unitCostMinorUnits ?? this.unitCostMinorUnits,
  );
  PurchaseOrderLine copyWithCompanion(PurchaseOrderLinesCompanion data) {
    return PurchaseOrderLine(
      id: data.id.present ? data.id.value : this.id,
      purchaseOrderId: data.purchaseOrderId.present
          ? data.purchaseOrderId.value
          : this.purchaseOrderId,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantityOrdered: data.quantityOrdered.present
          ? data.quantityOrdered.value
          : this.quantityOrdered,
      quantityReceived: data.quantityReceived.present
          ? data.quantityReceived.value
          : this.quantityReceived,
      unitCostMinorUnits: data.unitCostMinorUnits.present
          ? data.unitCostMinorUnits.value
          : this.unitCostMinorUnits,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseOrderLine(')
          ..write('id: $id, ')
          ..write('purchaseOrderId: $purchaseOrderId, ')
          ..write('productId: $productId, ')
          ..write('quantityOrdered: $quantityOrdered, ')
          ..write('quantityReceived: $quantityReceived, ')
          ..write('unitCostMinorUnits: $unitCostMinorUnits')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    purchaseOrderId,
    productId,
    quantityOrdered,
    quantityReceived,
    unitCostMinorUnits,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseOrderLine &&
          other.id == this.id &&
          other.purchaseOrderId == this.purchaseOrderId &&
          other.productId == this.productId &&
          other.quantityOrdered == this.quantityOrdered &&
          other.quantityReceived == this.quantityReceived &&
          other.unitCostMinorUnits == this.unitCostMinorUnits);
}

class PurchaseOrderLinesCompanion extends UpdateCompanion<PurchaseOrderLine> {
  final Value<String> id;
  final Value<String> purchaseOrderId;
  final Value<String> productId;
  final Value<int> quantityOrdered;
  final Value<int> quantityReceived;
  final Value<int> unitCostMinorUnits;
  final Value<int> rowid;
  const PurchaseOrderLinesCompanion({
    this.id = const Value.absent(),
    this.purchaseOrderId = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantityOrdered = const Value.absent(),
    this.quantityReceived = const Value.absent(),
    this.unitCostMinorUnits = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseOrderLinesCompanion.insert({
    required String id,
    required String purchaseOrderId,
    required String productId,
    required int quantityOrdered,
    this.quantityReceived = const Value.absent(),
    required int unitCostMinorUnits,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       purchaseOrderId = Value(purchaseOrderId),
       productId = Value(productId),
       quantityOrdered = Value(quantityOrdered),
       unitCostMinorUnits = Value(unitCostMinorUnits);
  static Insertable<PurchaseOrderLine> custom({
    Expression<String>? id,
    Expression<String>? purchaseOrderId,
    Expression<String>? productId,
    Expression<int>? quantityOrdered,
    Expression<int>? quantityReceived,
    Expression<int>? unitCostMinorUnits,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (purchaseOrderId != null) 'purchase_order_id': purchaseOrderId,
      if (productId != null) 'product_id': productId,
      if (quantityOrdered != null) 'quantity_ordered': quantityOrdered,
      if (quantityReceived != null) 'quantity_received': quantityReceived,
      if (unitCostMinorUnits != null)
        'unit_cost_minor_units': unitCostMinorUnits,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseOrderLinesCompanion copyWith({
    Value<String>? id,
    Value<String>? purchaseOrderId,
    Value<String>? productId,
    Value<int>? quantityOrdered,
    Value<int>? quantityReceived,
    Value<int>? unitCostMinorUnits,
    Value<int>? rowid,
  }) {
    return PurchaseOrderLinesCompanion(
      id: id ?? this.id,
      purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
      productId: productId ?? this.productId,
      quantityOrdered: quantityOrdered ?? this.quantityOrdered,
      quantityReceived: quantityReceived ?? this.quantityReceived,
      unitCostMinorUnits: unitCostMinorUnits ?? this.unitCostMinorUnits,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (purchaseOrderId.present) {
      map['purchase_order_id'] = Variable<String>(purchaseOrderId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (quantityOrdered.present) {
      map['quantity_ordered'] = Variable<int>(quantityOrdered.value);
    }
    if (quantityReceived.present) {
      map['quantity_received'] = Variable<int>(quantityReceived.value);
    }
    if (unitCostMinorUnits.present) {
      map['unit_cost_minor_units'] = Variable<int>(unitCostMinorUnits.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseOrderLinesCompanion(')
          ..write('id: $id, ')
          ..write('purchaseOrderId: $purchaseOrderId, ')
          ..write('productId: $productId, ')
          ..write('quantityOrdered: $quantityOrdered, ')
          ..write('quantityReceived: $quantityReceived, ')
          ..write('unitCostMinorUnits: $unitCostMinorUnits, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiscountsTable extends Discounts
    with TableInfo<$DiscountsTable, Discount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiscountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedScopeMeta = const VerificationMeta(
    'appliedScope',
  );
  @override
  late final GeneratedColumn<String> appliedScope = GeneratedColumn<String>(
    'applied_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeTargetIdMeta = const VerificationMeta(
    'scopeTargetId',
  );
  @override
  late final GeneratedColumn<String> scopeTargetId = GeneratedColumn<String>(
    'scope_target_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    name,
    type,
    value,
    appliedScope,
    scopeTargetId,
    startDate,
    endDate,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'discounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Discount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('applied_scope')) {
      context.handle(
        _appliedScopeMeta,
        appliedScope.isAcceptableOrUnknown(
          data['applied_scope']!,
          _appliedScopeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_appliedScopeMeta);
    }
    if (data.containsKey('scope_target_id')) {
      context.handle(
        _scopeTargetIdMeta,
        scopeTargetId.isAcceptableOrUnknown(
          data['scope_target_id']!,
          _scopeTargetIdMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Discount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Discount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
      appliedScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}applied_scope'],
      )!,
      scopeTargetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_target_id'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $DiscountsTable createAlias(String alias) {
    return $DiscountsTable(attachedDatabase, alias);
  }
}

class Discount extends DataClass implements Insertable<Discount> {
  final String id;
  final String storeId;
  final String name;
  final String type;
  final int value;
  final String appliedScope;
  final String? scopeTargetId;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  const Discount({
    required this.id,
    required this.storeId,
    required this.name,
    required this.type,
    required this.value,
    required this.appliedScope,
    this.scopeTargetId,
    this.startDate,
    this.endDate,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['value'] = Variable<int>(value);
    map['applied_scope'] = Variable<String>(appliedScope);
    if (!nullToAbsent || scopeTargetId != null) {
      map['scope_target_id'] = Variable<String>(scopeTargetId);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  DiscountsCompanion toCompanion(bool nullToAbsent) {
    return DiscountsCompanion(
      id: Value(id),
      storeId: Value(storeId),
      name: Value(name),
      type: Value(type),
      value: Value(value),
      appliedScope: Value(appliedScope),
      scopeTargetId: scopeTargetId == null && nullToAbsent
          ? const Value.absent()
          : Value(scopeTargetId),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      isActive: Value(isActive),
    );
  }

  factory Discount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Discount(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      value: serializer.fromJson<int>(json['value']),
      appliedScope: serializer.fromJson<String>(json['appliedScope']),
      scopeTargetId: serializer.fromJson<String?>(json['scopeTargetId']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'value': serializer.toJson<int>(value),
      'appliedScope': serializer.toJson<String>(appliedScope),
      'scopeTargetId': serializer.toJson<String?>(scopeTargetId),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Discount copyWith({
    String? id,
    String? storeId,
    String? name,
    String? type,
    int? value,
    String? appliedScope,
    Value<String?> scopeTargetId = const Value.absent(),
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    bool? isActive,
  }) => Discount(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    name: name ?? this.name,
    type: type ?? this.type,
    value: value ?? this.value,
    appliedScope: appliedScope ?? this.appliedScope,
    scopeTargetId: scopeTargetId.present
        ? scopeTargetId.value
        : this.scopeTargetId,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    isActive: isActive ?? this.isActive,
  );
  Discount copyWithCompanion(DiscountsCompanion data) {
    return Discount(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      value: data.value.present ? data.value.value : this.value,
      appliedScope: data.appliedScope.present
          ? data.appliedScope.value
          : this.appliedScope,
      scopeTargetId: data.scopeTargetId.present
          ? data.scopeTargetId.value
          : this.scopeTargetId,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Discount(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('appliedScope: $appliedScope, ')
          ..write('scopeTargetId: $scopeTargetId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    name,
    type,
    value,
    appliedScope,
    scopeTargetId,
    startDate,
    endDate,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Discount &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.name == this.name &&
          other.type == this.type &&
          other.value == this.value &&
          other.appliedScope == this.appliedScope &&
          other.scopeTargetId == this.scopeTargetId &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.isActive == this.isActive);
}

class DiscountsCompanion extends UpdateCompanion<Discount> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> name;
  final Value<String> type;
  final Value<int> value;
  final Value<String> appliedScope;
  final Value<String?> scopeTargetId;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<bool> isActive;
  final Value<int> rowid;
  const DiscountsCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.value = const Value.absent(),
    this.appliedScope = const Value.absent(),
    this.scopeTargetId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiscountsCompanion.insert({
    required String id,
    required String storeId,
    required String name,
    required String type,
    required int value,
    required String appliedScope,
    this.scopeTargetId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       name = Value(name),
       type = Value(type),
       value = Value(value),
       appliedScope = Value(appliedScope);
  static Insertable<Discount> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? value,
    Expression<String>? appliedScope,
    Expression<String>? scopeTargetId,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (value != null) 'value': value,
      if (appliedScope != null) 'applied_scope': appliedScope,
      if (scopeTargetId != null) 'scope_target_id': scopeTargetId,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiscountsCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? name,
    Value<String>? type,
    Value<int>? value,
    Value<String>? appliedScope,
    Value<String?>? scopeTargetId,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return DiscountsCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      appliedScope: appliedScope ?? this.appliedScope,
      scopeTargetId: scopeTargetId ?? this.scopeTargetId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (appliedScope.present) {
      map['applied_scope'] = Variable<String>(appliedScope.value);
    }
    if (scopeTargetId.present) {
      map['scope_target_id'] = Variable<String>(scopeTargetId.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiscountsCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('appliedScope: $appliedScope, ')
          ..write('scopeTargetId: $scopeTargetId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    name,
    phone,
    address,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Customer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final String id;
  final String storeId;
  final String name;
  final String? phone;
  final String? address;
  final DateTime createdAt;
  const Customer({
    required this.id,
    required this.storeId,
    required this.name,
    this.phone,
    this.address,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      storeId: Value(storeId),
      name: Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      createdAt: Value(createdAt),
    );
  }

  factory Customer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      address: serializer.fromJson<String?>(json['address']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'address': serializer.toJson<String?>(address),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Customer copyWith({
    String? id,
    String? storeId,
    String? name,
    Value<String?> phone = const Value.absent(),
    Value<String?> address = const Value.absent(),
    DateTime? createdAt,
  }) => Customer(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    address: address.present ? address.value : this.address,
    createdAt: createdAt ?? this.createdAt,
  );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      address: data.address.present ? data.address.value : this.address,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, storeId, name, phone, address, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.address == this.address &&
          other.createdAt == this.createdAt);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> address;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required String storeId,
    required String name,
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Customer> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? address,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? name,
    Value<String?>? phone,
    Value<String?>? address,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DebtLedgerEntriesTable extends DebtLedgerEntries
    with TableInfo<$DebtLedgerEntriesTable, DebtLedgerEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtLedgerEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _branchIdMeta = const VerificationMeta(
    'branchId',
  );
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
    'branch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _journalEntryIdMeta = const VerificationMeta(
    'journalEntryId',
  );
  @override
  late final GeneratedColumn<String> journalEntryId = GeneratedColumn<String>(
    'journal_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalAmountMinorUnitsMeta =
      const VerificationMeta('originalAmountMinorUnits');
  @override
  late final GeneratedColumn<int> originalAmountMinorUnits =
      GeneratedColumn<int>(
        'original_amount_minor_units',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _amountPaidMinorUnitsMeta =
      const VerificationMeta('amountPaidMinorUnits');
  @override
  late final GeneratedColumn<int> amountPaidMinorUnits = GeneratedColumn<int>(
    'amount_paid_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _receiptRefMeta = const VerificationMeta(
    'receiptRef',
  );
  @override
  late final GeneratedColumn<String> receiptRef = GeneratedColumn<String>(
    'receipt_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    branchId,
    customerId,
    saleId,
    journalEntryId,
    originalAmountMinorUnits,
    amountPaidMinorUnits,
    receiptRef,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debt_ledger_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DebtLedgerEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(
        _branchIdMeta,
        branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    }
    if (data.containsKey('journal_entry_id')) {
      context.handle(
        _journalEntryIdMeta,
        journalEntryId.isAcceptableOrUnknown(
          data['journal_entry_id']!,
          _journalEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('original_amount_minor_units')) {
      context.handle(
        _originalAmountMinorUnitsMeta,
        originalAmountMinorUnits.isAcceptableOrUnknown(
          data['original_amount_minor_units']!,
          _originalAmountMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalAmountMinorUnitsMeta);
    }
    if (data.containsKey('amount_paid_minor_units')) {
      context.handle(
        _amountPaidMinorUnitsMeta,
        amountPaidMinorUnits.isAcceptableOrUnknown(
          data['amount_paid_minor_units']!,
          _amountPaidMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('receipt_ref')) {
      context.handle(
        _receiptRefMeta,
        receiptRef.isAcceptableOrUnknown(data['receipt_ref']!, _receiptRefMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DebtLedgerEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DebtLedgerEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      branchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      ),
      journalEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}journal_entry_id'],
      ),
      originalAmountMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_amount_minor_units'],
      )!,
      amountPaidMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paid_minor_units'],
      )!,
      receiptRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_ref'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DebtLedgerEntriesTable createAlias(String alias) {
    return $DebtLedgerEntriesTable(attachedDatabase, alias);
  }
}

class DebtLedgerEntry extends DataClass implements Insertable<DebtLedgerEntry> {
  final String id;
  final String storeId;
  final String branchId;
  final String customerId;
  final String? saleId;
  final String? journalEntryId;
  final int originalAmountMinorUnits;
  final int amountPaidMinorUnits;
  final String? receiptRef;
  final String status;
  final DateTime createdAt;
  const DebtLedgerEntry({
    required this.id,
    required this.storeId,
    required this.branchId,
    required this.customerId,
    this.saleId,
    this.journalEntryId,
    required this.originalAmountMinorUnits,
    required this.amountPaidMinorUnits,
    this.receiptRef,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['branch_id'] = Variable<String>(branchId);
    map['customer_id'] = Variable<String>(customerId);
    if (!nullToAbsent || saleId != null) {
      map['sale_id'] = Variable<String>(saleId);
    }
    if (!nullToAbsent || journalEntryId != null) {
      map['journal_entry_id'] = Variable<String>(journalEntryId);
    }
    map['original_amount_minor_units'] = Variable<int>(
      originalAmountMinorUnits,
    );
    map['amount_paid_minor_units'] = Variable<int>(amountPaidMinorUnits);
    if (!nullToAbsent || receiptRef != null) {
      map['receipt_ref'] = Variable<String>(receiptRef);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DebtLedgerEntriesCompanion toCompanion(bool nullToAbsent) {
    return DebtLedgerEntriesCompanion(
      id: Value(id),
      storeId: Value(storeId),
      branchId: Value(branchId),
      customerId: Value(customerId),
      saleId: saleId == null && nullToAbsent
          ? const Value.absent()
          : Value(saleId),
      journalEntryId: journalEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(journalEntryId),
      originalAmountMinorUnits: Value(originalAmountMinorUnits),
      amountPaidMinorUnits: Value(amountPaidMinorUnits),
      receiptRef: receiptRef == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptRef),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory DebtLedgerEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DebtLedgerEntry(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      branchId: serializer.fromJson<String>(json['branchId']),
      customerId: serializer.fromJson<String>(json['customerId']),
      saleId: serializer.fromJson<String?>(json['saleId']),
      journalEntryId: serializer.fromJson<String?>(json['journalEntryId']),
      originalAmountMinorUnits: serializer.fromJson<int>(
        json['originalAmountMinorUnits'],
      ),
      amountPaidMinorUnits: serializer.fromJson<int>(
        json['amountPaidMinorUnits'],
      ),
      receiptRef: serializer.fromJson<String?>(json['receiptRef']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'branchId': serializer.toJson<String>(branchId),
      'customerId': serializer.toJson<String>(customerId),
      'saleId': serializer.toJson<String?>(saleId),
      'journalEntryId': serializer.toJson<String?>(journalEntryId),
      'originalAmountMinorUnits': serializer.toJson<int>(
        originalAmountMinorUnits,
      ),
      'amountPaidMinorUnits': serializer.toJson<int>(amountPaidMinorUnits),
      'receiptRef': serializer.toJson<String?>(receiptRef),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DebtLedgerEntry copyWith({
    String? id,
    String? storeId,
    String? branchId,
    String? customerId,
    Value<String?> saleId = const Value.absent(),
    Value<String?> journalEntryId = const Value.absent(),
    int? originalAmountMinorUnits,
    int? amountPaidMinorUnits,
    Value<String?> receiptRef = const Value.absent(),
    String? status,
    DateTime? createdAt,
  }) => DebtLedgerEntry(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    branchId: branchId ?? this.branchId,
    customerId: customerId ?? this.customerId,
    saleId: saleId.present ? saleId.value : this.saleId,
    journalEntryId: journalEntryId.present
        ? journalEntryId.value
        : this.journalEntryId,
    originalAmountMinorUnits:
        originalAmountMinorUnits ?? this.originalAmountMinorUnits,
    amountPaidMinorUnits: amountPaidMinorUnits ?? this.amountPaidMinorUnits,
    receiptRef: receiptRef.present ? receiptRef.value : this.receiptRef,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  DebtLedgerEntry copyWithCompanion(DebtLedgerEntriesCompanion data) {
    return DebtLedgerEntry(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      journalEntryId: data.journalEntryId.present
          ? data.journalEntryId.value
          : this.journalEntryId,
      originalAmountMinorUnits: data.originalAmountMinorUnits.present
          ? data.originalAmountMinorUnits.value
          : this.originalAmountMinorUnits,
      amountPaidMinorUnits: data.amountPaidMinorUnits.present
          ? data.amountPaidMinorUnits.value
          : this.amountPaidMinorUnits,
      receiptRef: data.receiptRef.present
          ? data.receiptRef.value
          : this.receiptRef,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DebtLedgerEntry(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('branchId: $branchId, ')
          ..write('customerId: $customerId, ')
          ..write('saleId: $saleId, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('originalAmountMinorUnits: $originalAmountMinorUnits, ')
          ..write('amountPaidMinorUnits: $amountPaidMinorUnits, ')
          ..write('receiptRef: $receiptRef, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    branchId,
    customerId,
    saleId,
    journalEntryId,
    originalAmountMinorUnits,
    amountPaidMinorUnits,
    receiptRef,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DebtLedgerEntry &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.branchId == this.branchId &&
          other.customerId == this.customerId &&
          other.saleId == this.saleId &&
          other.journalEntryId == this.journalEntryId &&
          other.originalAmountMinorUnits == this.originalAmountMinorUnits &&
          other.amountPaidMinorUnits == this.amountPaidMinorUnits &&
          other.receiptRef == this.receiptRef &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class DebtLedgerEntriesCompanion extends UpdateCompanion<DebtLedgerEntry> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> branchId;
  final Value<String> customerId;
  final Value<String?> saleId;
  final Value<String?> journalEntryId;
  final Value<int> originalAmountMinorUnits;
  final Value<int> amountPaidMinorUnits;
  final Value<String?> receiptRef;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DebtLedgerEntriesCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.branchId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.saleId = const Value.absent(),
    this.journalEntryId = const Value.absent(),
    this.originalAmountMinorUnits = const Value.absent(),
    this.amountPaidMinorUnits = const Value.absent(),
    this.receiptRef = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DebtLedgerEntriesCompanion.insert({
    required String id,
    required String storeId,
    required String branchId,
    required String customerId,
    this.saleId = const Value.absent(),
    this.journalEntryId = const Value.absent(),
    required int originalAmountMinorUnits,
    this.amountPaidMinorUnits = const Value.absent(),
    this.receiptRef = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       branchId = Value(branchId),
       customerId = Value(customerId),
       originalAmountMinorUnits = Value(originalAmountMinorUnits),
       createdAt = Value(createdAt);
  static Insertable<DebtLedgerEntry> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? branchId,
    Expression<String>? customerId,
    Expression<String>? saleId,
    Expression<String>? journalEntryId,
    Expression<int>? originalAmountMinorUnits,
    Expression<int>? amountPaidMinorUnits,
    Expression<String>? receiptRef,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (branchId != null) 'branch_id': branchId,
      if (customerId != null) 'customer_id': customerId,
      if (saleId != null) 'sale_id': saleId,
      if (journalEntryId != null) 'journal_entry_id': journalEntryId,
      if (originalAmountMinorUnits != null)
        'original_amount_minor_units': originalAmountMinorUnits,
      if (amountPaidMinorUnits != null)
        'amount_paid_minor_units': amountPaidMinorUnits,
      if (receiptRef != null) 'receipt_ref': receiptRef,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DebtLedgerEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? branchId,
    Value<String>? customerId,
    Value<String?>? saleId,
    Value<String?>? journalEntryId,
    Value<int>? originalAmountMinorUnits,
    Value<int>? amountPaidMinorUnits,
    Value<String?>? receiptRef,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DebtLedgerEntriesCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      branchId: branchId ?? this.branchId,
      customerId: customerId ?? this.customerId,
      saleId: saleId ?? this.saleId,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      originalAmountMinorUnits:
          originalAmountMinorUnits ?? this.originalAmountMinorUnits,
      amountPaidMinorUnits: amountPaidMinorUnits ?? this.amountPaidMinorUnits,
      receiptRef: receiptRef ?? this.receiptRef,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (journalEntryId.present) {
      map['journal_entry_id'] = Variable<String>(journalEntryId.value);
    }
    if (originalAmountMinorUnits.present) {
      map['original_amount_minor_units'] = Variable<int>(
        originalAmountMinorUnits.value,
      );
    }
    if (amountPaidMinorUnits.present) {
      map['amount_paid_minor_units'] = Variable<int>(
        amountPaidMinorUnits.value,
      );
    }
    if (receiptRef.present) {
      map['receipt_ref'] = Variable<String>(receiptRef.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtLedgerEntriesCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('branchId: $branchId, ')
          ..write('customerId: $customerId, ')
          ..write('saleId: $saleId, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('originalAmountMinorUnits: $originalAmountMinorUnits, ')
          ..write('amountPaidMinorUnits: $amountPaidMinorUnits, ')
          ..write('receiptRef: $receiptRef, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DebtPaymentsTable extends DebtPayments
    with TableInfo<$DebtPaymentsTable, DebtPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _debtLedgerEntryIdMeta = const VerificationMeta(
    'debtLedgerEntryId',
  );
  @override
  late final GeneratedColumn<String> debtLedgerEntryId =
      GeneratedColumn<String>(
        'debt_ledger_entry_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _amountMinorUnitsMeta = const VerificationMeta(
    'amountMinorUnits',
  );
  @override
  late final GeneratedColumn<int> amountMinorUnits = GeneratedColumn<int>(
    'amount_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedByUserIdMeta = const VerificationMeta(
    'receivedByUserId',
  );
  @override
  late final GeneratedColumn<String> receivedByUserId = GeneratedColumn<String>(
    'received_by_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _journalEntryIdMeta = const VerificationMeta(
    'journalEntryId',
  );
  @override
  late final GeneratedColumn<String> journalEntryId = GeneratedColumn<String>(
    'journal_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<DateTime> paidAt = GeneratedColumn<DateTime>(
    'paid_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    debtLedgerEntryId,
    amountMinorUnits,
    paymentMethod,
    receivedByUserId,
    journalEntryId,
    paidAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debt_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<DebtPayment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('debt_ledger_entry_id')) {
      context.handle(
        _debtLedgerEntryIdMeta,
        debtLedgerEntryId.isAcceptableOrUnknown(
          data['debt_ledger_entry_id']!,
          _debtLedgerEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_debtLedgerEntryIdMeta);
    }
    if (data.containsKey('amount_minor_units')) {
      context.handle(
        _amountMinorUnitsMeta,
        amountMinorUnits.isAcceptableOrUnknown(
          data['amount_minor_units']!,
          _amountMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorUnitsMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('received_by_user_id')) {
      context.handle(
        _receivedByUserIdMeta,
        receivedByUserId.isAcceptableOrUnknown(
          data['received_by_user_id']!,
          _receivedByUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_receivedByUserIdMeta);
    }
    if (data.containsKey('journal_entry_id')) {
      context.handle(
        _journalEntryIdMeta,
        journalEntryId.isAcceptableOrUnknown(
          data['journal_entry_id']!,
          _journalEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('paid_at')) {
      context.handle(
        _paidAtMeta,
        paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta),
      );
    } else if (isInserting) {
      context.missing(_paidAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DebtPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DebtPayment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      debtLedgerEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}debt_ledger_entry_id'],
      )!,
      amountMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor_units'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      receivedByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}received_by_user_id'],
      )!,
      journalEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}journal_entry_id'],
      ),
      paidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_at'],
      )!,
    );
  }

  @override
  $DebtPaymentsTable createAlias(String alias) {
    return $DebtPaymentsTable(attachedDatabase, alias);
  }
}

class DebtPayment extends DataClass implements Insertable<DebtPayment> {
  final String id;
  final String debtLedgerEntryId;
  final int amountMinorUnits;
  final String paymentMethod;
  final String receivedByUserId;
  final String? journalEntryId;
  final DateTime paidAt;
  const DebtPayment({
    required this.id,
    required this.debtLedgerEntryId,
    required this.amountMinorUnits,
    required this.paymentMethod,
    required this.receivedByUserId,
    this.journalEntryId,
    required this.paidAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['debt_ledger_entry_id'] = Variable<String>(debtLedgerEntryId);
    map['amount_minor_units'] = Variable<int>(amountMinorUnits);
    map['payment_method'] = Variable<String>(paymentMethod);
    map['received_by_user_id'] = Variable<String>(receivedByUserId);
    if (!nullToAbsent || journalEntryId != null) {
      map['journal_entry_id'] = Variable<String>(journalEntryId);
    }
    map['paid_at'] = Variable<DateTime>(paidAt);
    return map;
  }

  DebtPaymentsCompanion toCompanion(bool nullToAbsent) {
    return DebtPaymentsCompanion(
      id: Value(id),
      debtLedgerEntryId: Value(debtLedgerEntryId),
      amountMinorUnits: Value(amountMinorUnits),
      paymentMethod: Value(paymentMethod),
      receivedByUserId: Value(receivedByUserId),
      journalEntryId: journalEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(journalEntryId),
      paidAt: Value(paidAt),
    );
  }

  factory DebtPayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DebtPayment(
      id: serializer.fromJson<String>(json['id']),
      debtLedgerEntryId: serializer.fromJson<String>(json['debtLedgerEntryId']),
      amountMinorUnits: serializer.fromJson<int>(json['amountMinorUnits']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      receivedByUserId: serializer.fromJson<String>(json['receivedByUserId']),
      journalEntryId: serializer.fromJson<String?>(json['journalEntryId']),
      paidAt: serializer.fromJson<DateTime>(json['paidAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'debtLedgerEntryId': serializer.toJson<String>(debtLedgerEntryId),
      'amountMinorUnits': serializer.toJson<int>(amountMinorUnits),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'receivedByUserId': serializer.toJson<String>(receivedByUserId),
      'journalEntryId': serializer.toJson<String?>(journalEntryId),
      'paidAt': serializer.toJson<DateTime>(paidAt),
    };
  }

  DebtPayment copyWith({
    String? id,
    String? debtLedgerEntryId,
    int? amountMinorUnits,
    String? paymentMethod,
    String? receivedByUserId,
    Value<String?> journalEntryId = const Value.absent(),
    DateTime? paidAt,
  }) => DebtPayment(
    id: id ?? this.id,
    debtLedgerEntryId: debtLedgerEntryId ?? this.debtLedgerEntryId,
    amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    receivedByUserId: receivedByUserId ?? this.receivedByUserId,
    journalEntryId: journalEntryId.present
        ? journalEntryId.value
        : this.journalEntryId,
    paidAt: paidAt ?? this.paidAt,
  );
  DebtPayment copyWithCompanion(DebtPaymentsCompanion data) {
    return DebtPayment(
      id: data.id.present ? data.id.value : this.id,
      debtLedgerEntryId: data.debtLedgerEntryId.present
          ? data.debtLedgerEntryId.value
          : this.debtLedgerEntryId,
      amountMinorUnits: data.amountMinorUnits.present
          ? data.amountMinorUnits.value
          : this.amountMinorUnits,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      receivedByUserId: data.receivedByUserId.present
          ? data.receivedByUserId.value
          : this.receivedByUserId,
      journalEntryId: data.journalEntryId.present
          ? data.journalEntryId.value
          : this.journalEntryId,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DebtPayment(')
          ..write('id: $id, ')
          ..write('debtLedgerEntryId: $debtLedgerEntryId, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('receivedByUserId: $receivedByUserId, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('paidAt: $paidAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    debtLedgerEntryId,
    amountMinorUnits,
    paymentMethod,
    receivedByUserId,
    journalEntryId,
    paidAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DebtPayment &&
          other.id == this.id &&
          other.debtLedgerEntryId == this.debtLedgerEntryId &&
          other.amountMinorUnits == this.amountMinorUnits &&
          other.paymentMethod == this.paymentMethod &&
          other.receivedByUserId == this.receivedByUserId &&
          other.journalEntryId == this.journalEntryId &&
          other.paidAt == this.paidAt);
}

class DebtPaymentsCompanion extends UpdateCompanion<DebtPayment> {
  final Value<String> id;
  final Value<String> debtLedgerEntryId;
  final Value<int> amountMinorUnits;
  final Value<String> paymentMethod;
  final Value<String> receivedByUserId;
  final Value<String?> journalEntryId;
  final Value<DateTime> paidAt;
  final Value<int> rowid;
  const DebtPaymentsCompanion({
    this.id = const Value.absent(),
    this.debtLedgerEntryId = const Value.absent(),
    this.amountMinorUnits = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.receivedByUserId = const Value.absent(),
    this.journalEntryId = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DebtPaymentsCompanion.insert({
    required String id,
    required String debtLedgerEntryId,
    required int amountMinorUnits,
    required String paymentMethod,
    required String receivedByUserId,
    this.journalEntryId = const Value.absent(),
    required DateTime paidAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       debtLedgerEntryId = Value(debtLedgerEntryId),
       amountMinorUnits = Value(amountMinorUnits),
       paymentMethod = Value(paymentMethod),
       receivedByUserId = Value(receivedByUserId),
       paidAt = Value(paidAt);
  static Insertable<DebtPayment> custom({
    Expression<String>? id,
    Expression<String>? debtLedgerEntryId,
    Expression<int>? amountMinorUnits,
    Expression<String>? paymentMethod,
    Expression<String>? receivedByUserId,
    Expression<String>? journalEntryId,
    Expression<DateTime>? paidAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (debtLedgerEntryId != null) 'debt_ledger_entry_id': debtLedgerEntryId,
      if (amountMinorUnits != null) 'amount_minor_units': amountMinorUnits,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (receivedByUserId != null) 'received_by_user_id': receivedByUserId,
      if (journalEntryId != null) 'journal_entry_id': journalEntryId,
      if (paidAt != null) 'paid_at': paidAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DebtPaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? debtLedgerEntryId,
    Value<int>? amountMinorUnits,
    Value<String>? paymentMethod,
    Value<String>? receivedByUserId,
    Value<String?>? journalEntryId,
    Value<DateTime>? paidAt,
    Value<int>? rowid,
  }) {
    return DebtPaymentsCompanion(
      id: id ?? this.id,
      debtLedgerEntryId: debtLedgerEntryId ?? this.debtLedgerEntryId,
      amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receivedByUserId: receivedByUserId ?? this.receivedByUserId,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      paidAt: paidAt ?? this.paidAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (debtLedgerEntryId.present) {
      map['debt_ledger_entry_id'] = Variable<String>(debtLedgerEntryId.value);
    }
    if (amountMinorUnits.present) {
      map['amount_minor_units'] = Variable<int>(amountMinorUnits.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (receivedByUserId.present) {
      map['received_by_user_id'] = Variable<String>(receivedByUserId.value);
    }
    if (journalEntryId.present) {
      map['journal_entry_id'] = Variable<String>(journalEntryId.value);
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<DateTime>(paidAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('debtLedgerEntryId: $debtLedgerEntryId, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('receivedByUserId: $receivedByUserId, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('paidAt: $paidAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SuppliersTable extends Suppliers
    with TableInfo<$SuppliersTable, Supplier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactPhoneMeta = const VerificationMeta(
    'contactPhone',
  );
  @override
  late final GeneratedColumn<String> contactPhone = GeneratedColumn<String>(
    'contact_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contactPersonMeta = const VerificationMeta(
    'contactPerson',
  );
  @override
  late final GeneratedColumn<String> contactPerson = GeneratedColumn<String>(
    'contact_person',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    name,
    contactPhone,
    contactPerson,
    address,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suppliers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Supplier> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('contact_phone')) {
      context.handle(
        _contactPhoneMeta,
        contactPhone.isAcceptableOrUnknown(
          data['contact_phone']!,
          _contactPhoneMeta,
        ),
      );
    }
    if (data.containsKey('contact_person')) {
      context.handle(
        _contactPersonMeta,
        contactPerson.isAcceptableOrUnknown(
          data['contact_person']!,
          _contactPersonMeta,
        ),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Supplier map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Supplier(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      contactPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_phone'],
      ),
      contactPerson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_person'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SuppliersTable createAlias(String alias) {
    return $SuppliersTable(attachedDatabase, alias);
  }
}

class Supplier extends DataClass implements Insertable<Supplier> {
  final String id;
  final String storeId;
  final String name;
  final String? contactPhone;
  final String? contactPerson;
  final String? address;
  final DateTime createdAt;
  const Supplier({
    required this.id,
    required this.storeId,
    required this.name,
    this.contactPhone,
    this.contactPerson,
    this.address,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || contactPhone != null) {
      map['contact_phone'] = Variable<String>(contactPhone);
    }
    if (!nullToAbsent || contactPerson != null) {
      map['contact_person'] = Variable<String>(contactPerson);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SuppliersCompanion toCompanion(bool nullToAbsent) {
    return SuppliersCompanion(
      id: Value(id),
      storeId: Value(storeId),
      name: Value(name),
      contactPhone: contactPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(contactPhone),
      contactPerson: contactPerson == null && nullToAbsent
          ? const Value.absent()
          : Value(contactPerson),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      createdAt: Value(createdAt),
    );
  }

  factory Supplier.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Supplier(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      name: serializer.fromJson<String>(json['name']),
      contactPhone: serializer.fromJson<String?>(json['contactPhone']),
      contactPerson: serializer.fromJson<String?>(json['contactPerson']),
      address: serializer.fromJson<String?>(json['address']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'name': serializer.toJson<String>(name),
      'contactPhone': serializer.toJson<String?>(contactPhone),
      'contactPerson': serializer.toJson<String?>(contactPerson),
      'address': serializer.toJson<String?>(address),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Supplier copyWith({
    String? id,
    String? storeId,
    String? name,
    Value<String?> contactPhone = const Value.absent(),
    Value<String?> contactPerson = const Value.absent(),
    Value<String?> address = const Value.absent(),
    DateTime? createdAt,
  }) => Supplier(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    name: name ?? this.name,
    contactPhone: contactPhone.present ? contactPhone.value : this.contactPhone,
    contactPerson: contactPerson.present
        ? contactPerson.value
        : this.contactPerson,
    address: address.present ? address.value : this.address,
    createdAt: createdAt ?? this.createdAt,
  );
  Supplier copyWithCompanion(SuppliersCompanion data) {
    return Supplier(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      name: data.name.present ? data.name.value : this.name,
      contactPhone: data.contactPhone.present
          ? data.contactPhone.value
          : this.contactPhone,
      contactPerson: data.contactPerson.present
          ? data.contactPerson.value
          : this.contactPerson,
      address: data.address.present ? data.address.value : this.address,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Supplier(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('name: $name, ')
          ..write('contactPhone: $contactPhone, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('address: $address, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    name,
    contactPhone,
    contactPerson,
    address,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Supplier &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.name == this.name &&
          other.contactPhone == this.contactPhone &&
          other.contactPerson == this.contactPerson &&
          other.address == this.address &&
          other.createdAt == this.createdAt);
}

class SuppliersCompanion extends UpdateCompanion<Supplier> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> name;
  final Value<String?> contactPhone;
  final Value<String?> contactPerson;
  final Value<String?> address;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SuppliersCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.name = const Value.absent(),
    this.contactPhone = const Value.absent(),
    this.contactPerson = const Value.absent(),
    this.address = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SuppliersCompanion.insert({
    required String id,
    required String storeId,
    required String name,
    this.contactPhone = const Value.absent(),
    this.contactPerson = const Value.absent(),
    this.address = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Supplier> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? name,
    Expression<String>? contactPhone,
    Expression<String>? contactPerson,
    Expression<String>? address,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (name != null) 'name': name,
      if (contactPhone != null) 'contact_phone': contactPhone,
      if (contactPerson != null) 'contact_person': contactPerson,
      if (address != null) 'address': address,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SuppliersCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? name,
    Value<String?>? contactPhone,
    Value<String?>? contactPerson,
    Value<String?>? address,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SuppliersCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      contactPhone: contactPhone ?? this.contactPhone,
      contactPerson: contactPerson ?? this.contactPerson,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (contactPhone.present) {
      map['contact_phone'] = Variable<String>(contactPhone.value);
    }
    if (contactPerson.present) {
      map['contact_person'] = Variable<String>(contactPerson.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppliersCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('name: $name, ')
          ..write('contactPhone: $contactPhone, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('address: $address, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupplierTransactionsTable extends SupplierTransactions
    with TableInfo<$SupplierTransactionsTable, SupplierTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplierTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorUnitsMeta = const VerificationMeta(
    'amountMinorUnits',
  );
  @override
  late final GeneratedColumn<int> amountMinorUnits = GeneratedColumn<int>(
    'amount_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relatedPurchaseOrderIdMeta =
      const VerificationMeta('relatedPurchaseOrderId');
  @override
  late final GeneratedColumn<String> relatedPurchaseOrderId =
      GeneratedColumn<String>(
        'related_purchase_order_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _deliveryDateMeta = const VerificationMeta(
    'deliveryDate',
  );
  @override
  late final GeneratedColumn<DateTime> deliveryDate = GeneratedColumn<DateTime>(
    'delivery_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _journalEntryIdMeta = const VerificationMeta(
    'journalEntryId',
  );
  @override
  late final GeneratedColumn<String> journalEntryId = GeneratedColumn<String>(
    'journal_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByUserIdMeta = const VerificationMeta(
    'createdByUserId',
  );
  @override
  late final GeneratedColumn<String> createdByUserId = GeneratedColumn<String>(
    'created_by_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    supplierId,
    type,
    amountMinorUnits,
    relatedPurchaseOrderId,
    deliveryDate,
    journalEntryId,
    createdByUserId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplier_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplierTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_supplierIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount_minor_units')) {
      context.handle(
        _amountMinorUnitsMeta,
        amountMinorUnits.isAcceptableOrUnknown(
          data['amount_minor_units']!,
          _amountMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorUnitsMeta);
    }
    if (data.containsKey('related_purchase_order_id')) {
      context.handle(
        _relatedPurchaseOrderIdMeta,
        relatedPurchaseOrderId.isAcceptableOrUnknown(
          data['related_purchase_order_id']!,
          _relatedPurchaseOrderIdMeta,
        ),
      );
    }
    if (data.containsKey('delivery_date')) {
      context.handle(
        _deliveryDateMeta,
        deliveryDate.isAcceptableOrUnknown(
          data['delivery_date']!,
          _deliveryDateMeta,
        ),
      );
    }
    if (data.containsKey('journal_entry_id')) {
      context.handle(
        _journalEntryIdMeta,
        journalEntryId.isAcceptableOrUnknown(
          data['journal_entry_id']!,
          _journalEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('created_by_user_id')) {
      context.handle(
        _createdByUserIdMeta,
        createdByUserId.isAcceptableOrUnknown(
          data['created_by_user_id']!,
          _createdByUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdByUserIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplierTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amountMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor_units'],
      )!,
      relatedPurchaseOrderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_purchase_order_id'],
      ),
      deliveryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}delivery_date'],
      ),
      journalEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}journal_entry_id'],
      ),
      createdByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SupplierTransactionsTable createAlias(String alias) {
    return $SupplierTransactionsTable(attachedDatabase, alias);
  }
}

class SupplierTransaction extends DataClass
    implements Insertable<SupplierTransaction> {
  final String id;
  final String storeId;
  final String supplierId;
  final String type;
  final int amountMinorUnits;
  final String? relatedPurchaseOrderId;
  final DateTime? deliveryDate;
  final String? journalEntryId;
  final String createdByUserId;
  final DateTime createdAt;
  const SupplierTransaction({
    required this.id,
    required this.storeId,
    required this.supplierId,
    required this.type,
    required this.amountMinorUnits,
    this.relatedPurchaseOrderId,
    this.deliveryDate,
    this.journalEntryId,
    required this.createdByUserId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['supplier_id'] = Variable<String>(supplierId);
    map['type'] = Variable<String>(type);
    map['amount_minor_units'] = Variable<int>(amountMinorUnits);
    if (!nullToAbsent || relatedPurchaseOrderId != null) {
      map['related_purchase_order_id'] = Variable<String>(
        relatedPurchaseOrderId,
      );
    }
    if (!nullToAbsent || deliveryDate != null) {
      map['delivery_date'] = Variable<DateTime>(deliveryDate);
    }
    if (!nullToAbsent || journalEntryId != null) {
      map['journal_entry_id'] = Variable<String>(journalEntryId);
    }
    map['created_by_user_id'] = Variable<String>(createdByUserId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SupplierTransactionsCompanion toCompanion(bool nullToAbsent) {
    return SupplierTransactionsCompanion(
      id: Value(id),
      storeId: Value(storeId),
      supplierId: Value(supplierId),
      type: Value(type),
      amountMinorUnits: Value(amountMinorUnits),
      relatedPurchaseOrderId: relatedPurchaseOrderId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedPurchaseOrderId),
      deliveryDate: deliveryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryDate),
      journalEntryId: journalEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(journalEntryId),
      createdByUserId: Value(createdByUserId),
      createdAt: Value(createdAt),
    );
  }

  factory SupplierTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierTransaction(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      supplierId: serializer.fromJson<String>(json['supplierId']),
      type: serializer.fromJson<String>(json['type']),
      amountMinorUnits: serializer.fromJson<int>(json['amountMinorUnits']),
      relatedPurchaseOrderId: serializer.fromJson<String?>(
        json['relatedPurchaseOrderId'],
      ),
      deliveryDate: serializer.fromJson<DateTime?>(json['deliveryDate']),
      journalEntryId: serializer.fromJson<String?>(json['journalEntryId']),
      createdByUserId: serializer.fromJson<String>(json['createdByUserId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'supplierId': serializer.toJson<String>(supplierId),
      'type': serializer.toJson<String>(type),
      'amountMinorUnits': serializer.toJson<int>(amountMinorUnits),
      'relatedPurchaseOrderId': serializer.toJson<String?>(
        relatedPurchaseOrderId,
      ),
      'deliveryDate': serializer.toJson<DateTime?>(deliveryDate),
      'journalEntryId': serializer.toJson<String?>(journalEntryId),
      'createdByUserId': serializer.toJson<String>(createdByUserId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SupplierTransaction copyWith({
    String? id,
    String? storeId,
    String? supplierId,
    String? type,
    int? amountMinorUnits,
    Value<String?> relatedPurchaseOrderId = const Value.absent(),
    Value<DateTime?> deliveryDate = const Value.absent(),
    Value<String?> journalEntryId = const Value.absent(),
    String? createdByUserId,
    DateTime? createdAt,
  }) => SupplierTransaction(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    supplierId: supplierId ?? this.supplierId,
    type: type ?? this.type,
    amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
    relatedPurchaseOrderId: relatedPurchaseOrderId.present
        ? relatedPurchaseOrderId.value
        : this.relatedPurchaseOrderId,
    deliveryDate: deliveryDate.present ? deliveryDate.value : this.deliveryDate,
    journalEntryId: journalEntryId.present
        ? journalEntryId.value
        : this.journalEntryId,
    createdByUserId: createdByUserId ?? this.createdByUserId,
    createdAt: createdAt ?? this.createdAt,
  );
  SupplierTransaction copyWithCompanion(SupplierTransactionsCompanion data) {
    return SupplierTransaction(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      type: data.type.present ? data.type.value : this.type,
      amountMinorUnits: data.amountMinorUnits.present
          ? data.amountMinorUnits.value
          : this.amountMinorUnits,
      relatedPurchaseOrderId: data.relatedPurchaseOrderId.present
          ? data.relatedPurchaseOrderId.value
          : this.relatedPurchaseOrderId,
      deliveryDate: data.deliveryDate.present
          ? data.deliveryDate.value
          : this.deliveryDate,
      journalEntryId: data.journalEntryId.present
          ? data.journalEntryId.value
          : this.journalEntryId,
      createdByUserId: data.createdByUserId.present
          ? data.createdByUserId.value
          : this.createdByUserId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierTransaction(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('supplierId: $supplierId, ')
          ..write('type: $type, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('relatedPurchaseOrderId: $relatedPurchaseOrderId, ')
          ..write('deliveryDate: $deliveryDate, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    supplierId,
    type,
    amountMinorUnits,
    relatedPurchaseOrderId,
    deliveryDate,
    journalEntryId,
    createdByUserId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierTransaction &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.supplierId == this.supplierId &&
          other.type == this.type &&
          other.amountMinorUnits == this.amountMinorUnits &&
          other.relatedPurchaseOrderId == this.relatedPurchaseOrderId &&
          other.deliveryDate == this.deliveryDate &&
          other.journalEntryId == this.journalEntryId &&
          other.createdByUserId == this.createdByUserId &&
          other.createdAt == this.createdAt);
}

class SupplierTransactionsCompanion
    extends UpdateCompanion<SupplierTransaction> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> supplierId;
  final Value<String> type;
  final Value<int> amountMinorUnits;
  final Value<String?> relatedPurchaseOrderId;
  final Value<DateTime?> deliveryDate;
  final Value<String?> journalEntryId;
  final Value<String> createdByUserId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SupplierTransactionsCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.type = const Value.absent(),
    this.amountMinorUnits = const Value.absent(),
    this.relatedPurchaseOrderId = const Value.absent(),
    this.deliveryDate = const Value.absent(),
    this.journalEntryId = const Value.absent(),
    this.createdByUserId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SupplierTransactionsCompanion.insert({
    required String id,
    required String storeId,
    required String supplierId,
    required String type,
    required int amountMinorUnits,
    this.relatedPurchaseOrderId = const Value.absent(),
    this.deliveryDate = const Value.absent(),
    this.journalEntryId = const Value.absent(),
    required String createdByUserId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       supplierId = Value(supplierId),
       type = Value(type),
       amountMinorUnits = Value(amountMinorUnits),
       createdByUserId = Value(createdByUserId),
       createdAt = Value(createdAt);
  static Insertable<SupplierTransaction> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? supplierId,
    Expression<String>? type,
    Expression<int>? amountMinorUnits,
    Expression<String>? relatedPurchaseOrderId,
    Expression<DateTime>? deliveryDate,
    Expression<String>? journalEntryId,
    Expression<String>? createdByUserId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (supplierId != null) 'supplier_id': supplierId,
      if (type != null) 'type': type,
      if (amountMinorUnits != null) 'amount_minor_units': amountMinorUnits,
      if (relatedPurchaseOrderId != null)
        'related_purchase_order_id': relatedPurchaseOrderId,
      if (deliveryDate != null) 'delivery_date': deliveryDate,
      if (journalEntryId != null) 'journal_entry_id': journalEntryId,
      if (createdByUserId != null) 'created_by_user_id': createdByUserId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SupplierTransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? supplierId,
    Value<String>? type,
    Value<int>? amountMinorUnits,
    Value<String?>? relatedPurchaseOrderId,
    Value<DateTime?>? deliveryDate,
    Value<String?>? journalEntryId,
    Value<String>? createdByUserId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SupplierTransactionsCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      supplierId: supplierId ?? this.supplierId,
      type: type ?? this.type,
      amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
      relatedPurchaseOrderId:
          relatedPurchaseOrderId ?? this.relatedPurchaseOrderId,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amountMinorUnits.present) {
      map['amount_minor_units'] = Variable<int>(amountMinorUnits.value);
    }
    if (relatedPurchaseOrderId.present) {
      map['related_purchase_order_id'] = Variable<String>(
        relatedPurchaseOrderId.value,
      );
    }
    if (deliveryDate.present) {
      map['delivery_date'] = Variable<DateTime>(deliveryDate.value);
    }
    if (journalEntryId.present) {
      map['journal_entry_id'] = Variable<String>(journalEntryId.value);
    }
    if (createdByUserId.present) {
      map['created_by_user_id'] = Variable<String>(createdByUserId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplierTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('supplierId: $supplierId, ')
          ..write('type: $type, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('relatedPurchaseOrderId: $relatedPurchaseOrderId, ')
          ..write('deliveryDate: $deliveryDate, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChartOfAccountsTable extends ChartOfAccounts
    with TableInfo<$ChartOfAccountsTable, ChartOfAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChartOfAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentAccountIdMeta = const VerificationMeta(
    'parentAccountId',
  );
  @override
  late final GeneratedColumn<String> parentAccountId = GeneratedColumn<String>(
    'parent_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSystemAccountMeta = const VerificationMeta(
    'isSystemAccount',
  );
  @override
  late final GeneratedColumn<bool> isSystemAccount = GeneratedColumn<bool>(
    'is_system_account',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system_account" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    code,
    name,
    type,
    parentAccountId,
    isSystemAccount,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chart_of_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChartOfAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('parent_account_id')) {
      context.handle(
        _parentAccountIdMeta,
        parentAccountId.isAcceptableOrUnknown(
          data['parent_account_id']!,
          _parentAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('is_system_account')) {
      context.handle(
        _isSystemAccountMeta,
        isSystemAccount.isAcceptableOrUnknown(
          data['is_system_account']!,
          _isSystemAccountMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChartOfAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChartOfAccount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      parentAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_account_id'],
      ),
      isSystemAccount: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system_account'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $ChartOfAccountsTable createAlias(String alias) {
    return $ChartOfAccountsTable(attachedDatabase, alias);
  }
}

class ChartOfAccount extends DataClass implements Insertable<ChartOfAccount> {
  final String id;
  final String storeId;
  final String code;
  final String name;
  final String type;
  final String? parentAccountId;
  final bool isSystemAccount;
  final bool isActive;
  const ChartOfAccount({
    required this.id,
    required this.storeId,
    required this.code,
    required this.name,
    required this.type,
    this.parentAccountId,
    required this.isSystemAccount,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || parentAccountId != null) {
      map['parent_account_id'] = Variable<String>(parentAccountId);
    }
    map['is_system_account'] = Variable<bool>(isSystemAccount);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  ChartOfAccountsCompanion toCompanion(bool nullToAbsent) {
    return ChartOfAccountsCompanion(
      id: Value(id),
      storeId: Value(storeId),
      code: Value(code),
      name: Value(name),
      type: Value(type),
      parentAccountId: parentAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentAccountId),
      isSystemAccount: Value(isSystemAccount),
      isActive: Value(isActive),
    );
  }

  factory ChartOfAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChartOfAccount(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      parentAccountId: serializer.fromJson<String?>(json['parentAccountId']),
      isSystemAccount: serializer.fromJson<bool>(json['isSystemAccount']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'parentAccountId': serializer.toJson<String?>(parentAccountId),
      'isSystemAccount': serializer.toJson<bool>(isSystemAccount),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  ChartOfAccount copyWith({
    String? id,
    String? storeId,
    String? code,
    String? name,
    String? type,
    Value<String?> parentAccountId = const Value.absent(),
    bool? isSystemAccount,
    bool? isActive,
  }) => ChartOfAccount(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    code: code ?? this.code,
    name: name ?? this.name,
    type: type ?? this.type,
    parentAccountId: parentAccountId.present
        ? parentAccountId.value
        : this.parentAccountId,
    isSystemAccount: isSystemAccount ?? this.isSystemAccount,
    isActive: isActive ?? this.isActive,
  );
  ChartOfAccount copyWithCompanion(ChartOfAccountsCompanion data) {
    return ChartOfAccount(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      parentAccountId: data.parentAccountId.present
          ? data.parentAccountId.value
          : this.parentAccountId,
      isSystemAccount: data.isSystemAccount.present
          ? data.isSystemAccount.value
          : this.isSystemAccount,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChartOfAccount(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('parentAccountId: $parentAccountId, ')
          ..write('isSystemAccount: $isSystemAccount, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    code,
    name,
    type,
    parentAccountId,
    isSystemAccount,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChartOfAccount &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.code == this.code &&
          other.name == this.name &&
          other.type == this.type &&
          other.parentAccountId == this.parentAccountId &&
          other.isSystemAccount == this.isSystemAccount &&
          other.isActive == this.isActive);
}

class ChartOfAccountsCompanion extends UpdateCompanion<ChartOfAccount> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> code;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> parentAccountId;
  final Value<bool> isSystemAccount;
  final Value<bool> isActive;
  final Value<int> rowid;
  const ChartOfAccountsCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.parentAccountId = const Value.absent(),
    this.isSystemAccount = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChartOfAccountsCompanion.insert({
    required String id,
    required String storeId,
    required String code,
    required String name,
    required String type,
    this.parentAccountId = const Value.absent(),
    this.isSystemAccount = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       code = Value(code),
       name = Value(name),
       type = Value(type);
  static Insertable<ChartOfAccount> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? parentAccountId,
    Expression<bool>? isSystemAccount,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (parentAccountId != null) 'parent_account_id': parentAccountId,
      if (isSystemAccount != null) 'is_system_account': isSystemAccount,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChartOfAccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? code,
    Value<String>? name,
    Value<String>? type,
    Value<String?>? parentAccountId,
    Value<bool>? isSystemAccount,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return ChartOfAccountsCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      code: code ?? this.code,
      name: name ?? this.name,
      type: type ?? this.type,
      parentAccountId: parentAccountId ?? this.parentAccountId,
      isSystemAccount: isSystemAccount ?? this.isSystemAccount,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (parentAccountId.present) {
      map['parent_account_id'] = Variable<String>(parentAccountId.value);
    }
    if (isSystemAccount.present) {
      map['is_system_account'] = Variable<bool>(isSystemAccount.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChartOfAccountsCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('parentAccountId: $parentAccountId, ')
          ..write('isSystemAccount: $isSystemAccount, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalEntriesTable extends JournalEntries
    with TableInfo<$JournalEntriesTable, JournalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _branchIdMeta = const VerificationMeta(
    'branchId',
  );
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
    'branch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<DateTime> entryDate = GeneratedColumn<DateTime>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceTypeMeta = const VerificationMeta(
    'referenceType',
  );
  @override
  late final GeneratedColumn<String> referenceType = GeneratedColumn<String>(
    'reference_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceIdMeta = const VerificationMeta(
    'referenceId',
  );
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
    'reference_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdByUserIdMeta = const VerificationMeta(
    'createdByUserId',
  );
  @override
  late final GeneratedColumn<String> createdByUserId = GeneratedColumn<String>(
    'created_by_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReversalMeta = const VerificationMeta(
    'isReversal',
  );
  @override
  late final GeneratedColumn<bool> isReversal = GeneratedColumn<bool>(
    'is_reversal',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_reversal" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reversalOfEntryIdMeta = const VerificationMeta(
    'reversalOfEntryId',
  );
  @override
  late final GeneratedColumn<String> reversalOfEntryId =
      GeneratedColumn<String>(
        'reversal_of_entry_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    branchId,
    entryDate,
    referenceType,
    referenceId,
    memo,
    createdByUserId,
    isReversal,
    reversalOfEntryId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(
        _branchIdMeta,
        branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('reference_type')) {
      context.handle(
        _referenceTypeMeta,
        referenceType.isAcceptableOrUnknown(
          data['reference_type']!,
          _referenceTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_referenceTypeMeta);
    }
    if (data.containsKey('reference_id')) {
      context.handle(
        _referenceIdMeta,
        referenceId.isAcceptableOrUnknown(
          data['reference_id']!,
          _referenceIdMeta,
        ),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('created_by_user_id')) {
      context.handle(
        _createdByUserIdMeta,
        createdByUserId.isAcceptableOrUnknown(
          data['created_by_user_id']!,
          _createdByUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdByUserIdMeta);
    }
    if (data.containsKey('is_reversal')) {
      context.handle(
        _isReversalMeta,
        isReversal.isAcceptableOrUnknown(data['is_reversal']!, _isReversalMeta),
      );
    }
    if (data.containsKey('reversal_of_entry_id')) {
      context.handle(
        _reversalOfEntryIdMeta,
        reversalOfEntryId.isAcceptableOrUnknown(
          data['reversal_of_entry_id']!,
          _reversalOfEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      branchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_id'],
      )!,
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}entry_date'],
      )!,
      referenceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_type'],
      )!,
      referenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_id'],
      ),
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      )!,
      createdByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_user_id'],
      )!,
      isReversal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_reversal'],
      )!,
      reversalOfEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reversal_of_entry_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $JournalEntriesTable createAlias(String alias) {
    return $JournalEntriesTable(attachedDatabase, alias);
  }
}

class JournalEntry extends DataClass implements Insertable<JournalEntry> {
  final String id;
  final String storeId;
  final String branchId;
  final DateTime entryDate;
  final String referenceType;
  final String? referenceId;
  final String memo;
  final String createdByUserId;
  final bool isReversal;
  final String? reversalOfEntryId;
  final DateTime createdAt;
  const JournalEntry({
    required this.id,
    required this.storeId,
    required this.branchId,
    required this.entryDate,
    required this.referenceType,
    this.referenceId,
    required this.memo,
    required this.createdByUserId,
    required this.isReversal,
    this.reversalOfEntryId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['branch_id'] = Variable<String>(branchId);
    map['entry_date'] = Variable<DateTime>(entryDate);
    map['reference_type'] = Variable<String>(referenceType);
    if (!nullToAbsent || referenceId != null) {
      map['reference_id'] = Variable<String>(referenceId);
    }
    map['memo'] = Variable<String>(memo);
    map['created_by_user_id'] = Variable<String>(createdByUserId);
    map['is_reversal'] = Variable<bool>(isReversal);
    if (!nullToAbsent || reversalOfEntryId != null) {
      map['reversal_of_entry_id'] = Variable<String>(reversalOfEntryId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  JournalEntriesCompanion toCompanion(bool nullToAbsent) {
    return JournalEntriesCompanion(
      id: Value(id),
      storeId: Value(storeId),
      branchId: Value(branchId),
      entryDate: Value(entryDate),
      referenceType: Value(referenceType),
      referenceId: referenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceId),
      memo: Value(memo),
      createdByUserId: Value(createdByUserId),
      isReversal: Value(isReversal),
      reversalOfEntryId: reversalOfEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(reversalOfEntryId),
      createdAt: Value(createdAt),
    );
  }

  factory JournalEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalEntry(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      branchId: serializer.fromJson<String>(json['branchId']),
      entryDate: serializer.fromJson<DateTime>(json['entryDate']),
      referenceType: serializer.fromJson<String>(json['referenceType']),
      referenceId: serializer.fromJson<String?>(json['referenceId']),
      memo: serializer.fromJson<String>(json['memo']),
      createdByUserId: serializer.fromJson<String>(json['createdByUserId']),
      isReversal: serializer.fromJson<bool>(json['isReversal']),
      reversalOfEntryId: serializer.fromJson<String?>(
        json['reversalOfEntryId'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'branchId': serializer.toJson<String>(branchId),
      'entryDate': serializer.toJson<DateTime>(entryDate),
      'referenceType': serializer.toJson<String>(referenceType),
      'referenceId': serializer.toJson<String?>(referenceId),
      'memo': serializer.toJson<String>(memo),
      'createdByUserId': serializer.toJson<String>(createdByUserId),
      'isReversal': serializer.toJson<bool>(isReversal),
      'reversalOfEntryId': serializer.toJson<String?>(reversalOfEntryId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  JournalEntry copyWith({
    String? id,
    String? storeId,
    String? branchId,
    DateTime? entryDate,
    String? referenceType,
    Value<String?> referenceId = const Value.absent(),
    String? memo,
    String? createdByUserId,
    bool? isReversal,
    Value<String?> reversalOfEntryId = const Value.absent(),
    DateTime? createdAt,
  }) => JournalEntry(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    branchId: branchId ?? this.branchId,
    entryDate: entryDate ?? this.entryDate,
    referenceType: referenceType ?? this.referenceType,
    referenceId: referenceId.present ? referenceId.value : this.referenceId,
    memo: memo ?? this.memo,
    createdByUserId: createdByUserId ?? this.createdByUserId,
    isReversal: isReversal ?? this.isReversal,
    reversalOfEntryId: reversalOfEntryId.present
        ? reversalOfEntryId.value
        : this.reversalOfEntryId,
    createdAt: createdAt ?? this.createdAt,
  );
  JournalEntry copyWithCompanion(JournalEntriesCompanion data) {
    return JournalEntry(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      referenceType: data.referenceType.present
          ? data.referenceType.value
          : this.referenceType,
      referenceId: data.referenceId.present
          ? data.referenceId.value
          : this.referenceId,
      memo: data.memo.present ? data.memo.value : this.memo,
      createdByUserId: data.createdByUserId.present
          ? data.createdByUserId.value
          : this.createdByUserId,
      isReversal: data.isReversal.present
          ? data.isReversal.value
          : this.isReversal,
      reversalOfEntryId: data.reversalOfEntryId.present
          ? data.reversalOfEntryId.value
          : this.reversalOfEntryId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntry(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('branchId: $branchId, ')
          ..write('entryDate: $entryDate, ')
          ..write('referenceType: $referenceType, ')
          ..write('referenceId: $referenceId, ')
          ..write('memo: $memo, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('isReversal: $isReversal, ')
          ..write('reversalOfEntryId: $reversalOfEntryId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    branchId,
    entryDate,
    referenceType,
    referenceId,
    memo,
    createdByUserId,
    isReversal,
    reversalOfEntryId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalEntry &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.branchId == this.branchId &&
          other.entryDate == this.entryDate &&
          other.referenceType == this.referenceType &&
          other.referenceId == this.referenceId &&
          other.memo == this.memo &&
          other.createdByUserId == this.createdByUserId &&
          other.isReversal == this.isReversal &&
          other.reversalOfEntryId == this.reversalOfEntryId &&
          other.createdAt == this.createdAt);
}

class JournalEntriesCompanion extends UpdateCompanion<JournalEntry> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> branchId;
  final Value<DateTime> entryDate;
  final Value<String> referenceType;
  final Value<String?> referenceId;
  final Value<String> memo;
  final Value<String> createdByUserId;
  final Value<bool> isReversal;
  final Value<String?> reversalOfEntryId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const JournalEntriesCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.branchId = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdByUserId = const Value.absent(),
    this.isReversal = const Value.absent(),
    this.reversalOfEntryId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalEntriesCompanion.insert({
    required String id,
    required String storeId,
    required String branchId,
    required DateTime entryDate,
    required String referenceType,
    this.referenceId = const Value.absent(),
    this.memo = const Value.absent(),
    required String createdByUserId,
    this.isReversal = const Value.absent(),
    this.reversalOfEntryId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       branchId = Value(branchId),
       entryDate = Value(entryDate),
       referenceType = Value(referenceType),
       createdByUserId = Value(createdByUserId),
       createdAt = Value(createdAt);
  static Insertable<JournalEntry> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? branchId,
    Expression<DateTime>? entryDate,
    Expression<String>? referenceType,
    Expression<String>? referenceId,
    Expression<String>? memo,
    Expression<String>? createdByUserId,
    Expression<bool>? isReversal,
    Expression<String>? reversalOfEntryId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (branchId != null) 'branch_id': branchId,
      if (entryDate != null) 'entry_date': entryDate,
      if (referenceType != null) 'reference_type': referenceType,
      if (referenceId != null) 'reference_id': referenceId,
      if (memo != null) 'memo': memo,
      if (createdByUserId != null) 'created_by_user_id': createdByUserId,
      if (isReversal != null) 'is_reversal': isReversal,
      if (reversalOfEntryId != null) 'reversal_of_entry_id': reversalOfEntryId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? branchId,
    Value<DateTime>? entryDate,
    Value<String>? referenceType,
    Value<String?>? referenceId,
    Value<String>? memo,
    Value<String>? createdByUserId,
    Value<bool>? isReversal,
    Value<String?>? reversalOfEntryId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return JournalEntriesCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      branchId: branchId ?? this.branchId,
      entryDate: entryDate ?? this.entryDate,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      memo: memo ?? this.memo,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      isReversal: isReversal ?? this.isReversal,
      reversalOfEntryId: reversalOfEntryId ?? this.reversalOfEntryId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<DateTime>(entryDate.value);
    }
    if (referenceType.present) {
      map['reference_type'] = Variable<String>(referenceType.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (createdByUserId.present) {
      map['created_by_user_id'] = Variable<String>(createdByUserId.value);
    }
    if (isReversal.present) {
      map['is_reversal'] = Variable<bool>(isReversal.value);
    }
    if (reversalOfEntryId.present) {
      map['reversal_of_entry_id'] = Variable<String>(reversalOfEntryId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('branchId: $branchId, ')
          ..write('entryDate: $entryDate, ')
          ..write('referenceType: $referenceType, ')
          ..write('referenceId: $referenceId, ')
          ..write('memo: $memo, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('isReversal: $isReversal, ')
          ..write('reversalOfEntryId: $reversalOfEntryId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalLinesTable extends JournalLines
    with TableInfo<$JournalLinesTable, JournalLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _journalEntryIdMeta = const VerificationMeta(
    'journalEntryId',
  );
  @override
  late final GeneratedColumn<String> journalEntryId = GeneratedColumn<String>(
    'journal_entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _debitMinorUnitsMeta = const VerificationMeta(
    'debitMinorUnits',
  );
  @override
  late final GeneratedColumn<int> debitMinorUnits = GeneratedColumn<int>(
    'debit_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _creditMinorUnitsMeta = const VerificationMeta(
    'creditMinorUnits',
  );
  @override
  late final GeneratedColumn<int> creditMinorUnits = GeneratedColumn<int>(
    'credit_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    journalEntryId,
    accountId,
    debitMinorUnits,
    creditMinorUnits,
    description,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalLine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('journal_entry_id')) {
      context.handle(
        _journalEntryIdMeta,
        journalEntryId.isAcceptableOrUnknown(
          data['journal_entry_id']!,
          _journalEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_journalEntryIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('debit_minor_units')) {
      context.handle(
        _debitMinorUnitsMeta,
        debitMinorUnits.isAcceptableOrUnknown(
          data['debit_minor_units']!,
          _debitMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('credit_minor_units')) {
      context.handle(
        _creditMinorUnitsMeta,
        creditMinorUnits.isAcceptableOrUnknown(
          data['credit_minor_units']!,
          _creditMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalLine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      journalEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}journal_entry_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      debitMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}debit_minor_units'],
      )!,
      creditMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credit_minor_units'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
    );
  }

  @override
  $JournalLinesTable createAlias(String alias) {
    return $JournalLinesTable(attachedDatabase, alias);
  }
}

class JournalLine extends DataClass implements Insertable<JournalLine> {
  final String id;
  final String storeId;
  final String journalEntryId;
  final String accountId;
  final int debitMinorUnits;
  final int creditMinorUnits;
  final String description;
  const JournalLine({
    required this.id,
    required this.storeId,
    required this.journalEntryId,
    required this.accountId,
    required this.debitMinorUnits,
    required this.creditMinorUnits,
    required this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['journal_entry_id'] = Variable<String>(journalEntryId);
    map['account_id'] = Variable<String>(accountId);
    map['debit_minor_units'] = Variable<int>(debitMinorUnits);
    map['credit_minor_units'] = Variable<int>(creditMinorUnits);
    map['description'] = Variable<String>(description);
    return map;
  }

  JournalLinesCompanion toCompanion(bool nullToAbsent) {
    return JournalLinesCompanion(
      id: Value(id),
      storeId: Value(storeId),
      journalEntryId: Value(journalEntryId),
      accountId: Value(accountId),
      debitMinorUnits: Value(debitMinorUnits),
      creditMinorUnits: Value(creditMinorUnits),
      description: Value(description),
    );
  }

  factory JournalLine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalLine(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      journalEntryId: serializer.fromJson<String>(json['journalEntryId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      debitMinorUnits: serializer.fromJson<int>(json['debitMinorUnits']),
      creditMinorUnits: serializer.fromJson<int>(json['creditMinorUnits']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'journalEntryId': serializer.toJson<String>(journalEntryId),
      'accountId': serializer.toJson<String>(accountId),
      'debitMinorUnits': serializer.toJson<int>(debitMinorUnits),
      'creditMinorUnits': serializer.toJson<int>(creditMinorUnits),
      'description': serializer.toJson<String>(description),
    };
  }

  JournalLine copyWith({
    String? id,
    String? storeId,
    String? journalEntryId,
    String? accountId,
    int? debitMinorUnits,
    int? creditMinorUnits,
    String? description,
  }) => JournalLine(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    journalEntryId: journalEntryId ?? this.journalEntryId,
    accountId: accountId ?? this.accountId,
    debitMinorUnits: debitMinorUnits ?? this.debitMinorUnits,
    creditMinorUnits: creditMinorUnits ?? this.creditMinorUnits,
    description: description ?? this.description,
  );
  JournalLine copyWithCompanion(JournalLinesCompanion data) {
    return JournalLine(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      journalEntryId: data.journalEntryId.present
          ? data.journalEntryId.value
          : this.journalEntryId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      debitMinorUnits: data.debitMinorUnits.present
          ? data.debitMinorUnits.value
          : this.debitMinorUnits,
      creditMinorUnits: data.creditMinorUnits.present
          ? data.creditMinorUnits.value
          : this.creditMinorUnits,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalLine(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('accountId: $accountId, ')
          ..write('debitMinorUnits: $debitMinorUnits, ')
          ..write('creditMinorUnits: $creditMinorUnits, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    journalEntryId,
    accountId,
    debitMinorUnits,
    creditMinorUnits,
    description,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalLine &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.journalEntryId == this.journalEntryId &&
          other.accountId == this.accountId &&
          other.debitMinorUnits == this.debitMinorUnits &&
          other.creditMinorUnits == this.creditMinorUnits &&
          other.description == this.description);
}

class JournalLinesCompanion extends UpdateCompanion<JournalLine> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> journalEntryId;
  final Value<String> accountId;
  final Value<int> debitMinorUnits;
  final Value<int> creditMinorUnits;
  final Value<String> description;
  final Value<int> rowid;
  const JournalLinesCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.journalEntryId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.debitMinorUnits = const Value.absent(),
    this.creditMinorUnits = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalLinesCompanion.insert({
    required String id,
    required String storeId,
    required String journalEntryId,
    required String accountId,
    this.debitMinorUnits = const Value.absent(),
    this.creditMinorUnits = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       journalEntryId = Value(journalEntryId),
       accountId = Value(accountId);
  static Insertable<JournalLine> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? journalEntryId,
    Expression<String>? accountId,
    Expression<int>? debitMinorUnits,
    Expression<int>? creditMinorUnits,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (journalEntryId != null) 'journal_entry_id': journalEntryId,
      if (accountId != null) 'account_id': accountId,
      if (debitMinorUnits != null) 'debit_minor_units': debitMinorUnits,
      if (creditMinorUnits != null) 'credit_minor_units': creditMinorUnits,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalLinesCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? journalEntryId,
    Value<String>? accountId,
    Value<int>? debitMinorUnits,
    Value<int>? creditMinorUnits,
    Value<String>? description,
    Value<int>? rowid,
  }) {
    return JournalLinesCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      accountId: accountId ?? this.accountId,
      debitMinorUnits: debitMinorUnits ?? this.debitMinorUnits,
      creditMinorUnits: creditMinorUnits ?? this.creditMinorUnits,
      description: description ?? this.description,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (journalEntryId.present) {
      map['journal_entry_id'] = Variable<String>(journalEntryId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (debitMinorUnits.present) {
      map['debit_minor_units'] = Variable<int>(debitMinorUnits.value);
    }
    if (creditMinorUnits.present) {
      map['credit_minor_units'] = Variable<int>(creditMinorUnits.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalLinesCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('accountId: $accountId, ')
          ..write('debitMinorUnits: $debitMinorUnits, ')
          ..write('creditMinorUnits: $creditMinorUnits, ')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesTable extends Sales with TableInfo<$SalesTable, Sale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _branchIdMeta = const VerificationMeta(
    'branchId',
  );
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
    'branch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleNumberMeta = const VerificationMeta(
    'saleNumber',
  );
  @override
  late final GeneratedColumn<String> saleNumber = GeneratedColumn<String>(
    'sale_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _holdLabelMeta = const VerificationMeta(
    'holdLabel',
  );
  @override
  late final GeneratedColumn<String> holdLabel = GeneratedColumn<String>(
    'hold_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subtotalMinorUnitsMeta =
      const VerificationMeta('subtotalMinorUnits');
  @override
  late final GeneratedColumn<int> subtotalMinorUnits = GeneratedColumn<int>(
    'subtotal_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discountTotalMinorUnitsMeta =
      const VerificationMeta('discountTotalMinorUnits');
  @override
  late final GeneratedColumn<int> discountTotalMinorUnits =
      GeneratedColumn<int>(
        'discount_total_minor_units',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _taxTotalMinorUnitsMeta =
      const VerificationMeta('taxTotalMinorUnits');
  @override
  late final GeneratedColumn<int> taxTotalMinorUnits = GeneratedColumn<int>(
    'tax_total_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _grandTotalMinorUnitsMeta =
      const VerificationMeta('grandTotalMinorUnits');
  @override
  late final GeneratedColumn<int> grandTotalMinorUnits = GeneratedColumn<int>(
    'grand_total_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountTenderedMinorUnitsMeta =
      const VerificationMeta('amountTenderedMinorUnits');
  @override
  late final GeneratedColumn<int> amountTenderedMinorUnits =
      GeneratedColumn<int>(
        'amount_tendered_minor_units',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _changeGivenMinorUnitsMeta =
      const VerificationMeta('changeGivenMinorUnits');
  @override
  late final GeneratedColumn<int> changeGivenMinorUnits = GeneratedColumn<int>(
    'change_given_minor_units',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shiftIdMeta = const VerificationMeta(
    'shiftId',
  );
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
    'shift_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cashierIdMeta = const VerificationMeta(
    'cashierId',
  );
  @override
  late final GeneratedColumn<String> cashierId = GeneratedColumn<String>(
    'cashier_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _journalEntryIdMeta = const VerificationMeta(
    'journalEntryId',
  );
  @override
  late final GeneratedColumn<String> journalEntryId = GeneratedColumn<String>(
    'journal_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    branchId,
    saleNumber,
    status,
    customerId,
    holdLabel,
    subtotalMinorUnits,
    discountTotalMinorUnits,
    taxTotalMinorUnits,
    grandTotalMinorUnits,
    paymentMethod,
    amountTenderedMinorUnits,
    changeGivenMinorUnits,
    shiftId,
    cashierId,
    journalEntryId,
    createdAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(
        _branchIdMeta,
        branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('sale_number')) {
      context.handle(
        _saleNumberMeta,
        saleNumber.isAcceptableOrUnknown(data['sale_number']!, _saleNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_saleNumberMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('hold_label')) {
      context.handle(
        _holdLabelMeta,
        holdLabel.isAcceptableOrUnknown(data['hold_label']!, _holdLabelMeta),
      );
    }
    if (data.containsKey('subtotal_minor_units')) {
      context.handle(
        _subtotalMinorUnitsMeta,
        subtotalMinorUnits.isAcceptableOrUnknown(
          data['subtotal_minor_units']!,
          _subtotalMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('discount_total_minor_units')) {
      context.handle(
        _discountTotalMinorUnitsMeta,
        discountTotalMinorUnits.isAcceptableOrUnknown(
          data['discount_total_minor_units']!,
          _discountTotalMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('tax_total_minor_units')) {
      context.handle(
        _taxTotalMinorUnitsMeta,
        taxTotalMinorUnits.isAcceptableOrUnknown(
          data['tax_total_minor_units']!,
          _taxTotalMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('grand_total_minor_units')) {
      context.handle(
        _grandTotalMinorUnitsMeta,
        grandTotalMinorUnits.isAcceptableOrUnknown(
          data['grand_total_minor_units']!,
          _grandTotalMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    if (data.containsKey('amount_tendered_minor_units')) {
      context.handle(
        _amountTenderedMinorUnitsMeta,
        amountTenderedMinorUnits.isAcceptableOrUnknown(
          data['amount_tendered_minor_units']!,
          _amountTenderedMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('change_given_minor_units')) {
      context.handle(
        _changeGivenMinorUnitsMeta,
        changeGivenMinorUnits.isAcceptableOrUnknown(
          data['change_given_minor_units']!,
          _changeGivenMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('shift_id')) {
      context.handle(
        _shiftIdMeta,
        shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta),
      );
    }
    if (data.containsKey('cashier_id')) {
      context.handle(
        _cashierIdMeta,
        cashierId.isAcceptableOrUnknown(data['cashier_id']!, _cashierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cashierIdMeta);
    }
    if (data.containsKey('journal_entry_id')) {
      context.handle(
        _journalEntryIdMeta,
        journalEntryId.isAcceptableOrUnknown(
          data['journal_entry_id']!,
          _journalEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      branchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_id'],
      )!,
      saleNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_number'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      holdLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hold_label'],
      ),
      subtotalMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subtotal_minor_units'],
      )!,
      discountTotalMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_total_minor_units'],
      )!,
      taxTotalMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tax_total_minor_units'],
      )!,
      grandTotalMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grand_total_minor_units'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      ),
      amountTenderedMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_tendered_minor_units'],
      ),
      changeGivenMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}change_given_minor_units'],
      ),
      shiftId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shift_id'],
      ),
      cashierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cashier_id'],
      )!,
      journalEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}journal_entry_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class Sale extends DataClass implements Insertable<Sale> {
  final String id;
  final String storeId;
  final String branchId;
  final String saleNumber;
  final String status;
  final String? customerId;
  final String? holdLabel;
  final int subtotalMinorUnits;
  final int discountTotalMinorUnits;
  final int taxTotalMinorUnits;
  final int grandTotalMinorUnits;
  final String? paymentMethod;
  final int? amountTenderedMinorUnits;
  final int? changeGivenMinorUnits;
  final String? shiftId;
  final String cashierId;
  final String? journalEntryId;
  final DateTime createdAt;
  final DateTime? completedAt;
  const Sale({
    required this.id,
    required this.storeId,
    required this.branchId,
    required this.saleNumber,
    required this.status,
    this.customerId,
    this.holdLabel,
    required this.subtotalMinorUnits,
    required this.discountTotalMinorUnits,
    required this.taxTotalMinorUnits,
    required this.grandTotalMinorUnits,
    this.paymentMethod,
    this.amountTenderedMinorUnits,
    this.changeGivenMinorUnits,
    this.shiftId,
    required this.cashierId,
    this.journalEntryId,
    required this.createdAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['branch_id'] = Variable<String>(branchId);
    map['sale_number'] = Variable<String>(saleNumber);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    if (!nullToAbsent || holdLabel != null) {
      map['hold_label'] = Variable<String>(holdLabel);
    }
    map['subtotal_minor_units'] = Variable<int>(subtotalMinorUnits);
    map['discount_total_minor_units'] = Variable<int>(discountTotalMinorUnits);
    map['tax_total_minor_units'] = Variable<int>(taxTotalMinorUnits);
    map['grand_total_minor_units'] = Variable<int>(grandTotalMinorUnits);
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<String>(paymentMethod);
    }
    if (!nullToAbsent || amountTenderedMinorUnits != null) {
      map['amount_tendered_minor_units'] = Variable<int>(
        amountTenderedMinorUnits,
      );
    }
    if (!nullToAbsent || changeGivenMinorUnits != null) {
      map['change_given_minor_units'] = Variable<int>(changeGivenMinorUnits);
    }
    if (!nullToAbsent || shiftId != null) {
      map['shift_id'] = Variable<String>(shiftId);
    }
    map['cashier_id'] = Variable<String>(cashierId);
    if (!nullToAbsent || journalEntryId != null) {
      map['journal_entry_id'] = Variable<String>(journalEntryId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      id: Value(id),
      storeId: Value(storeId),
      branchId: Value(branchId),
      saleNumber: Value(saleNumber),
      status: Value(status),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      holdLabel: holdLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(holdLabel),
      subtotalMinorUnits: Value(subtotalMinorUnits),
      discountTotalMinorUnits: Value(discountTotalMinorUnits),
      taxTotalMinorUnits: Value(taxTotalMinorUnits),
      grandTotalMinorUnits: Value(grandTotalMinorUnits),
      paymentMethod: paymentMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethod),
      amountTenderedMinorUnits: amountTenderedMinorUnits == null && nullToAbsent
          ? const Value.absent()
          : Value(amountTenderedMinorUnits),
      changeGivenMinorUnits: changeGivenMinorUnits == null && nullToAbsent
          ? const Value.absent()
          : Value(changeGivenMinorUnits),
      shiftId: shiftId == null && nullToAbsent
          ? const Value.absent()
          : Value(shiftId),
      cashierId: Value(cashierId),
      journalEntryId: journalEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(journalEntryId),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory Sale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sale(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      branchId: serializer.fromJson<String>(json['branchId']),
      saleNumber: serializer.fromJson<String>(json['saleNumber']),
      status: serializer.fromJson<String>(json['status']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      holdLabel: serializer.fromJson<String?>(json['holdLabel']),
      subtotalMinorUnits: serializer.fromJson<int>(json['subtotalMinorUnits']),
      discountTotalMinorUnits: serializer.fromJson<int>(
        json['discountTotalMinorUnits'],
      ),
      taxTotalMinorUnits: serializer.fromJson<int>(json['taxTotalMinorUnits']),
      grandTotalMinorUnits: serializer.fromJson<int>(
        json['grandTotalMinorUnits'],
      ),
      paymentMethod: serializer.fromJson<String?>(json['paymentMethod']),
      amountTenderedMinorUnits: serializer.fromJson<int?>(
        json['amountTenderedMinorUnits'],
      ),
      changeGivenMinorUnits: serializer.fromJson<int?>(
        json['changeGivenMinorUnits'],
      ),
      shiftId: serializer.fromJson<String?>(json['shiftId']),
      cashierId: serializer.fromJson<String>(json['cashierId']),
      journalEntryId: serializer.fromJson<String?>(json['journalEntryId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'branchId': serializer.toJson<String>(branchId),
      'saleNumber': serializer.toJson<String>(saleNumber),
      'status': serializer.toJson<String>(status),
      'customerId': serializer.toJson<String?>(customerId),
      'holdLabel': serializer.toJson<String?>(holdLabel),
      'subtotalMinorUnits': serializer.toJson<int>(subtotalMinorUnits),
      'discountTotalMinorUnits': serializer.toJson<int>(
        discountTotalMinorUnits,
      ),
      'taxTotalMinorUnits': serializer.toJson<int>(taxTotalMinorUnits),
      'grandTotalMinorUnits': serializer.toJson<int>(grandTotalMinorUnits),
      'paymentMethod': serializer.toJson<String?>(paymentMethod),
      'amountTenderedMinorUnits': serializer.toJson<int?>(
        amountTenderedMinorUnits,
      ),
      'changeGivenMinorUnits': serializer.toJson<int?>(changeGivenMinorUnits),
      'shiftId': serializer.toJson<String?>(shiftId),
      'cashierId': serializer.toJson<String>(cashierId),
      'journalEntryId': serializer.toJson<String?>(journalEntryId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  Sale copyWith({
    String? id,
    String? storeId,
    String? branchId,
    String? saleNumber,
    String? status,
    Value<String?> customerId = const Value.absent(),
    Value<String?> holdLabel = const Value.absent(),
    int? subtotalMinorUnits,
    int? discountTotalMinorUnits,
    int? taxTotalMinorUnits,
    int? grandTotalMinorUnits,
    Value<String?> paymentMethod = const Value.absent(),
    Value<int?> amountTenderedMinorUnits = const Value.absent(),
    Value<int?> changeGivenMinorUnits = const Value.absent(),
    Value<String?> shiftId = const Value.absent(),
    String? cashierId,
    Value<String?> journalEntryId = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => Sale(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    branchId: branchId ?? this.branchId,
    saleNumber: saleNumber ?? this.saleNumber,
    status: status ?? this.status,
    customerId: customerId.present ? customerId.value : this.customerId,
    holdLabel: holdLabel.present ? holdLabel.value : this.holdLabel,
    subtotalMinorUnits: subtotalMinorUnits ?? this.subtotalMinorUnits,
    discountTotalMinorUnits:
        discountTotalMinorUnits ?? this.discountTotalMinorUnits,
    taxTotalMinorUnits: taxTotalMinorUnits ?? this.taxTotalMinorUnits,
    grandTotalMinorUnits: grandTotalMinorUnits ?? this.grandTotalMinorUnits,
    paymentMethod: paymentMethod.present
        ? paymentMethod.value
        : this.paymentMethod,
    amountTenderedMinorUnits: amountTenderedMinorUnits.present
        ? amountTenderedMinorUnits.value
        : this.amountTenderedMinorUnits,
    changeGivenMinorUnits: changeGivenMinorUnits.present
        ? changeGivenMinorUnits.value
        : this.changeGivenMinorUnits,
    shiftId: shiftId.present ? shiftId.value : this.shiftId,
    cashierId: cashierId ?? this.cashierId,
    journalEntryId: journalEntryId.present
        ? journalEntryId.value
        : this.journalEntryId,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  Sale copyWithCompanion(SalesCompanion data) {
    return Sale(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      saleNumber: data.saleNumber.present
          ? data.saleNumber.value
          : this.saleNumber,
      status: data.status.present ? data.status.value : this.status,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      holdLabel: data.holdLabel.present ? data.holdLabel.value : this.holdLabel,
      subtotalMinorUnits: data.subtotalMinorUnits.present
          ? data.subtotalMinorUnits.value
          : this.subtotalMinorUnits,
      discountTotalMinorUnits: data.discountTotalMinorUnits.present
          ? data.discountTotalMinorUnits.value
          : this.discountTotalMinorUnits,
      taxTotalMinorUnits: data.taxTotalMinorUnits.present
          ? data.taxTotalMinorUnits.value
          : this.taxTotalMinorUnits,
      grandTotalMinorUnits: data.grandTotalMinorUnits.present
          ? data.grandTotalMinorUnits.value
          : this.grandTotalMinorUnits,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      amountTenderedMinorUnits: data.amountTenderedMinorUnits.present
          ? data.amountTenderedMinorUnits.value
          : this.amountTenderedMinorUnits,
      changeGivenMinorUnits: data.changeGivenMinorUnits.present
          ? data.changeGivenMinorUnits.value
          : this.changeGivenMinorUnits,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      cashierId: data.cashierId.present ? data.cashierId.value : this.cashierId,
      journalEntryId: data.journalEntryId.present
          ? data.journalEntryId.value
          : this.journalEntryId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sale(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('branchId: $branchId, ')
          ..write('saleNumber: $saleNumber, ')
          ..write('status: $status, ')
          ..write('customerId: $customerId, ')
          ..write('holdLabel: $holdLabel, ')
          ..write('subtotalMinorUnits: $subtotalMinorUnits, ')
          ..write('discountTotalMinorUnits: $discountTotalMinorUnits, ')
          ..write('taxTotalMinorUnits: $taxTotalMinorUnits, ')
          ..write('grandTotalMinorUnits: $grandTotalMinorUnits, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('amountTenderedMinorUnits: $amountTenderedMinorUnits, ')
          ..write('changeGivenMinorUnits: $changeGivenMinorUnits, ')
          ..write('shiftId: $shiftId, ')
          ..write('cashierId: $cashierId, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    branchId,
    saleNumber,
    status,
    customerId,
    holdLabel,
    subtotalMinorUnits,
    discountTotalMinorUnits,
    taxTotalMinorUnits,
    grandTotalMinorUnits,
    paymentMethod,
    amountTenderedMinorUnits,
    changeGivenMinorUnits,
    shiftId,
    cashierId,
    journalEntryId,
    createdAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sale &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.branchId == this.branchId &&
          other.saleNumber == this.saleNumber &&
          other.status == this.status &&
          other.customerId == this.customerId &&
          other.holdLabel == this.holdLabel &&
          other.subtotalMinorUnits == this.subtotalMinorUnits &&
          other.discountTotalMinorUnits == this.discountTotalMinorUnits &&
          other.taxTotalMinorUnits == this.taxTotalMinorUnits &&
          other.grandTotalMinorUnits == this.grandTotalMinorUnits &&
          other.paymentMethod == this.paymentMethod &&
          other.amountTenderedMinorUnits == this.amountTenderedMinorUnits &&
          other.changeGivenMinorUnits == this.changeGivenMinorUnits &&
          other.shiftId == this.shiftId &&
          other.cashierId == this.cashierId &&
          other.journalEntryId == this.journalEntryId &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class SalesCompanion extends UpdateCompanion<Sale> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> branchId;
  final Value<String> saleNumber;
  final Value<String> status;
  final Value<String?> customerId;
  final Value<String?> holdLabel;
  final Value<int> subtotalMinorUnits;
  final Value<int> discountTotalMinorUnits;
  final Value<int> taxTotalMinorUnits;
  final Value<int> grandTotalMinorUnits;
  final Value<String?> paymentMethod;
  final Value<int?> amountTenderedMinorUnits;
  final Value<int?> changeGivenMinorUnits;
  final Value<String?> shiftId;
  final Value<String> cashierId;
  final Value<String?> journalEntryId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const SalesCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.branchId = const Value.absent(),
    this.saleNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.customerId = const Value.absent(),
    this.holdLabel = const Value.absent(),
    this.subtotalMinorUnits = const Value.absent(),
    this.discountTotalMinorUnits = const Value.absent(),
    this.taxTotalMinorUnits = const Value.absent(),
    this.grandTotalMinorUnits = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.amountTenderedMinorUnits = const Value.absent(),
    this.changeGivenMinorUnits = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.cashierId = const Value.absent(),
    this.journalEntryId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesCompanion.insert({
    required String id,
    required String storeId,
    required String branchId,
    required String saleNumber,
    required String status,
    this.customerId = const Value.absent(),
    this.holdLabel = const Value.absent(),
    this.subtotalMinorUnits = const Value.absent(),
    this.discountTotalMinorUnits = const Value.absent(),
    this.taxTotalMinorUnits = const Value.absent(),
    this.grandTotalMinorUnits = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.amountTenderedMinorUnits = const Value.absent(),
    this.changeGivenMinorUnits = const Value.absent(),
    this.shiftId = const Value.absent(),
    required String cashierId,
    this.journalEntryId = const Value.absent(),
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       branchId = Value(branchId),
       saleNumber = Value(saleNumber),
       status = Value(status),
       cashierId = Value(cashierId),
       createdAt = Value(createdAt);
  static Insertable<Sale> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? branchId,
    Expression<String>? saleNumber,
    Expression<String>? status,
    Expression<String>? customerId,
    Expression<String>? holdLabel,
    Expression<int>? subtotalMinorUnits,
    Expression<int>? discountTotalMinorUnits,
    Expression<int>? taxTotalMinorUnits,
    Expression<int>? grandTotalMinorUnits,
    Expression<String>? paymentMethod,
    Expression<int>? amountTenderedMinorUnits,
    Expression<int>? changeGivenMinorUnits,
    Expression<String>? shiftId,
    Expression<String>? cashierId,
    Expression<String>? journalEntryId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (branchId != null) 'branch_id': branchId,
      if (saleNumber != null) 'sale_number': saleNumber,
      if (status != null) 'status': status,
      if (customerId != null) 'customer_id': customerId,
      if (holdLabel != null) 'hold_label': holdLabel,
      if (subtotalMinorUnits != null)
        'subtotal_minor_units': subtotalMinorUnits,
      if (discountTotalMinorUnits != null)
        'discount_total_minor_units': discountTotalMinorUnits,
      if (taxTotalMinorUnits != null)
        'tax_total_minor_units': taxTotalMinorUnits,
      if (grandTotalMinorUnits != null)
        'grand_total_minor_units': grandTotalMinorUnits,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (amountTenderedMinorUnits != null)
        'amount_tendered_minor_units': amountTenderedMinorUnits,
      if (changeGivenMinorUnits != null)
        'change_given_minor_units': changeGivenMinorUnits,
      if (shiftId != null) 'shift_id': shiftId,
      if (cashierId != null) 'cashier_id': cashierId,
      if (journalEntryId != null) 'journal_entry_id': journalEntryId,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? branchId,
    Value<String>? saleNumber,
    Value<String>? status,
    Value<String?>? customerId,
    Value<String?>? holdLabel,
    Value<int>? subtotalMinorUnits,
    Value<int>? discountTotalMinorUnits,
    Value<int>? taxTotalMinorUnits,
    Value<int>? grandTotalMinorUnits,
    Value<String?>? paymentMethod,
    Value<int?>? amountTenderedMinorUnits,
    Value<int?>? changeGivenMinorUnits,
    Value<String?>? shiftId,
    Value<String>? cashierId,
    Value<String?>? journalEntryId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return SalesCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      branchId: branchId ?? this.branchId,
      saleNumber: saleNumber ?? this.saleNumber,
      status: status ?? this.status,
      customerId: customerId ?? this.customerId,
      holdLabel: holdLabel ?? this.holdLabel,
      subtotalMinorUnits: subtotalMinorUnits ?? this.subtotalMinorUnits,
      discountTotalMinorUnits:
          discountTotalMinorUnits ?? this.discountTotalMinorUnits,
      taxTotalMinorUnits: taxTotalMinorUnits ?? this.taxTotalMinorUnits,
      grandTotalMinorUnits: grandTotalMinorUnits ?? this.grandTotalMinorUnits,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountTenderedMinorUnits:
          amountTenderedMinorUnits ?? this.amountTenderedMinorUnits,
      changeGivenMinorUnits:
          changeGivenMinorUnits ?? this.changeGivenMinorUnits,
      shiftId: shiftId ?? this.shiftId,
      cashierId: cashierId ?? this.cashierId,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (saleNumber.present) {
      map['sale_number'] = Variable<String>(saleNumber.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (holdLabel.present) {
      map['hold_label'] = Variable<String>(holdLabel.value);
    }
    if (subtotalMinorUnits.present) {
      map['subtotal_minor_units'] = Variable<int>(subtotalMinorUnits.value);
    }
    if (discountTotalMinorUnits.present) {
      map['discount_total_minor_units'] = Variable<int>(
        discountTotalMinorUnits.value,
      );
    }
    if (taxTotalMinorUnits.present) {
      map['tax_total_minor_units'] = Variable<int>(taxTotalMinorUnits.value);
    }
    if (grandTotalMinorUnits.present) {
      map['grand_total_minor_units'] = Variable<int>(
        grandTotalMinorUnits.value,
      );
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (amountTenderedMinorUnits.present) {
      map['amount_tendered_minor_units'] = Variable<int>(
        amountTenderedMinorUnits.value,
      );
    }
    if (changeGivenMinorUnits.present) {
      map['change_given_minor_units'] = Variable<int>(
        changeGivenMinorUnits.value,
      );
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (cashierId.present) {
      map['cashier_id'] = Variable<String>(cashierId.value);
    }
    if (journalEntryId.present) {
      map['journal_entry_id'] = Variable<String>(journalEntryId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('branchId: $branchId, ')
          ..write('saleNumber: $saleNumber, ')
          ..write('status: $status, ')
          ..write('customerId: $customerId, ')
          ..write('holdLabel: $holdLabel, ')
          ..write('subtotalMinorUnits: $subtotalMinorUnits, ')
          ..write('discountTotalMinorUnits: $discountTotalMinorUnits, ')
          ..write('taxTotalMinorUnits: $taxTotalMinorUnits, ')
          ..write('grandTotalMinorUnits: $grandTotalMinorUnits, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('amountTenderedMinorUnits: $amountTenderedMinorUnits, ')
          ..write('changeGivenMinorUnits: $changeGivenMinorUnits, ')
          ..write('shiftId: $shiftId, ')
          ..write('cashierId: $cashierId, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleLinesTable extends SaleLines
    with TableInfo<$SaleLinesTable, SaleLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMinorUnitsMeta =
      const VerificationMeta('unitPriceMinorUnits');
  @override
  late final GeneratedColumn<int> unitPriceMinorUnits = GeneratedColumn<int>(
    'unit_price_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountAmountMinorUnitsMeta =
      const VerificationMeta('discountAmountMinorUnits');
  @override
  late final GeneratedColumn<int> discountAmountMinorUnits =
      GeneratedColumn<int>(
        'discount_amount_minor_units',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _taxAmountMinorUnitsMeta =
      const VerificationMeta('taxAmountMinorUnits');
  @override
  late final GeneratedColumn<int> taxAmountMinorUnits = GeneratedColumn<int>(
    'tax_amount_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lineTotalMinorUnitsMeta =
      const VerificationMeta('lineTotalMinorUnits');
  @override
  late final GeneratedColumn<int> lineTotalMinorUnits = GeneratedColumn<int>(
    'line_total_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costPriceSnapshotMinorUnitsMeta =
      const VerificationMeta('costPriceSnapshotMinorUnits');
  @override
  late final GeneratedColumn<int> costPriceSnapshotMinorUnits =
      GeneratedColumn<int>(
        'cost_price_snapshot_minor_units',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saleId,
    productId,
    quantity,
    unitPriceMinorUnits,
    discountAmountMinorUnits,
    taxAmountMinorUnits,
    lineTotalMinorUnits,
    costPriceSnapshotMinorUnits,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleLine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price_minor_units')) {
      context.handle(
        _unitPriceMinorUnitsMeta,
        unitPriceMinorUnits.isAcceptableOrUnknown(
          data['unit_price_minor_units']!,
          _unitPriceMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMinorUnitsMeta);
    }
    if (data.containsKey('discount_amount_minor_units')) {
      context.handle(
        _discountAmountMinorUnitsMeta,
        discountAmountMinorUnits.isAcceptableOrUnknown(
          data['discount_amount_minor_units']!,
          _discountAmountMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('tax_amount_minor_units')) {
      context.handle(
        _taxAmountMinorUnitsMeta,
        taxAmountMinorUnits.isAcceptableOrUnknown(
          data['tax_amount_minor_units']!,
          _taxAmountMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('line_total_minor_units')) {
      context.handle(
        _lineTotalMinorUnitsMeta,
        lineTotalMinorUnits.isAcceptableOrUnknown(
          data['line_total_minor_units']!,
          _lineTotalMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lineTotalMinorUnitsMeta);
    }
    if (data.containsKey('cost_price_snapshot_minor_units')) {
      context.handle(
        _costPriceSnapshotMinorUnitsMeta,
        costPriceSnapshotMinorUnits.isAcceptableOrUnknown(
          data['cost_price_snapshot_minor_units']!,
          _costPriceSnapshotMinorUnitsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleLine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      unitPriceMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_minor_units'],
      )!,
      discountAmountMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_amount_minor_units'],
      )!,
      taxAmountMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tax_amount_minor_units'],
      )!,
      lineTotalMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_total_minor_units'],
      )!,
      costPriceSnapshotMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost_price_snapshot_minor_units'],
      )!,
    );
  }

  @override
  $SaleLinesTable createAlias(String alias) {
    return $SaleLinesTable(attachedDatabase, alias);
  }
}

class SaleLine extends DataClass implements Insertable<SaleLine> {
  final String id;
  final String saleId;
  final String productId;
  final int quantity;
  final int unitPriceMinorUnits;
  final int discountAmountMinorUnits;
  final int taxAmountMinorUnits;
  final int lineTotalMinorUnits;
  final int costPriceSnapshotMinorUnits;
  const SaleLine({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.unitPriceMinorUnits,
    required this.discountAmountMinorUnits,
    required this.taxAmountMinorUnits,
    required this.lineTotalMinorUnits,
    required this.costPriceSnapshotMinorUnits,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sale_id'] = Variable<String>(saleId);
    map['product_id'] = Variable<String>(productId);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price_minor_units'] = Variable<int>(unitPriceMinorUnits);
    map['discount_amount_minor_units'] = Variable<int>(
      discountAmountMinorUnits,
    );
    map['tax_amount_minor_units'] = Variable<int>(taxAmountMinorUnits);
    map['line_total_minor_units'] = Variable<int>(lineTotalMinorUnits);
    map['cost_price_snapshot_minor_units'] = Variable<int>(
      costPriceSnapshotMinorUnits,
    );
    return map;
  }

  SaleLinesCompanion toCompanion(bool nullToAbsent) {
    return SaleLinesCompanion(
      id: Value(id),
      saleId: Value(saleId),
      productId: Value(productId),
      quantity: Value(quantity),
      unitPriceMinorUnits: Value(unitPriceMinorUnits),
      discountAmountMinorUnits: Value(discountAmountMinorUnits),
      taxAmountMinorUnits: Value(taxAmountMinorUnits),
      lineTotalMinorUnits: Value(lineTotalMinorUnits),
      costPriceSnapshotMinorUnits: Value(costPriceSnapshotMinorUnits),
    );
  }

  factory SaleLine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleLine(
      id: serializer.fromJson<String>(json['id']),
      saleId: serializer.fromJson<String>(json['saleId']),
      productId: serializer.fromJson<String>(json['productId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPriceMinorUnits: serializer.fromJson<int>(
        json['unitPriceMinorUnits'],
      ),
      discountAmountMinorUnits: serializer.fromJson<int>(
        json['discountAmountMinorUnits'],
      ),
      taxAmountMinorUnits: serializer.fromJson<int>(
        json['taxAmountMinorUnits'],
      ),
      lineTotalMinorUnits: serializer.fromJson<int>(
        json['lineTotalMinorUnits'],
      ),
      costPriceSnapshotMinorUnits: serializer.fromJson<int>(
        json['costPriceSnapshotMinorUnits'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saleId': serializer.toJson<String>(saleId),
      'productId': serializer.toJson<String>(productId),
      'quantity': serializer.toJson<int>(quantity),
      'unitPriceMinorUnits': serializer.toJson<int>(unitPriceMinorUnits),
      'discountAmountMinorUnits': serializer.toJson<int>(
        discountAmountMinorUnits,
      ),
      'taxAmountMinorUnits': serializer.toJson<int>(taxAmountMinorUnits),
      'lineTotalMinorUnits': serializer.toJson<int>(lineTotalMinorUnits),
      'costPriceSnapshotMinorUnits': serializer.toJson<int>(
        costPriceSnapshotMinorUnits,
      ),
    };
  }

  SaleLine copyWith({
    String? id,
    String? saleId,
    String? productId,
    int? quantity,
    int? unitPriceMinorUnits,
    int? discountAmountMinorUnits,
    int? taxAmountMinorUnits,
    int? lineTotalMinorUnits,
    int? costPriceSnapshotMinorUnits,
  }) => SaleLine(
    id: id ?? this.id,
    saleId: saleId ?? this.saleId,
    productId: productId ?? this.productId,
    quantity: quantity ?? this.quantity,
    unitPriceMinorUnits: unitPriceMinorUnits ?? this.unitPriceMinorUnits,
    discountAmountMinorUnits:
        discountAmountMinorUnits ?? this.discountAmountMinorUnits,
    taxAmountMinorUnits: taxAmountMinorUnits ?? this.taxAmountMinorUnits,
    lineTotalMinorUnits: lineTotalMinorUnits ?? this.lineTotalMinorUnits,
    costPriceSnapshotMinorUnits:
        costPriceSnapshotMinorUnits ?? this.costPriceSnapshotMinorUnits,
  );
  SaleLine copyWithCompanion(SaleLinesCompanion data) {
    return SaleLine(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPriceMinorUnits: data.unitPriceMinorUnits.present
          ? data.unitPriceMinorUnits.value
          : this.unitPriceMinorUnits,
      discountAmountMinorUnits: data.discountAmountMinorUnits.present
          ? data.discountAmountMinorUnits.value
          : this.discountAmountMinorUnits,
      taxAmountMinorUnits: data.taxAmountMinorUnits.present
          ? data.taxAmountMinorUnits.value
          : this.taxAmountMinorUnits,
      lineTotalMinorUnits: data.lineTotalMinorUnits.present
          ? data.lineTotalMinorUnits.value
          : this.lineTotalMinorUnits,
      costPriceSnapshotMinorUnits: data.costPriceSnapshotMinorUnits.present
          ? data.costPriceSnapshotMinorUnits.value
          : this.costPriceSnapshotMinorUnits,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleLine(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceMinorUnits: $unitPriceMinorUnits, ')
          ..write('discountAmountMinorUnits: $discountAmountMinorUnits, ')
          ..write('taxAmountMinorUnits: $taxAmountMinorUnits, ')
          ..write('lineTotalMinorUnits: $lineTotalMinorUnits, ')
          ..write('costPriceSnapshotMinorUnits: $costPriceSnapshotMinorUnits')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    saleId,
    productId,
    quantity,
    unitPriceMinorUnits,
    discountAmountMinorUnits,
    taxAmountMinorUnits,
    lineTotalMinorUnits,
    costPriceSnapshotMinorUnits,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleLine &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.productId == this.productId &&
          other.quantity == this.quantity &&
          other.unitPriceMinorUnits == this.unitPriceMinorUnits &&
          other.discountAmountMinorUnits == this.discountAmountMinorUnits &&
          other.taxAmountMinorUnits == this.taxAmountMinorUnits &&
          other.lineTotalMinorUnits == this.lineTotalMinorUnits &&
          other.costPriceSnapshotMinorUnits ==
              this.costPriceSnapshotMinorUnits);
}

class SaleLinesCompanion extends UpdateCompanion<SaleLine> {
  final Value<String> id;
  final Value<String> saleId;
  final Value<String> productId;
  final Value<int> quantity;
  final Value<int> unitPriceMinorUnits;
  final Value<int> discountAmountMinorUnits;
  final Value<int> taxAmountMinorUnits;
  final Value<int> lineTotalMinorUnits;
  final Value<int> costPriceSnapshotMinorUnits;
  final Value<int> rowid;
  const SaleLinesCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPriceMinorUnits = const Value.absent(),
    this.discountAmountMinorUnits = const Value.absent(),
    this.taxAmountMinorUnits = const Value.absent(),
    this.lineTotalMinorUnits = const Value.absent(),
    this.costPriceSnapshotMinorUnits = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleLinesCompanion.insert({
    required String id,
    required String saleId,
    required String productId,
    required int quantity,
    required int unitPriceMinorUnits,
    this.discountAmountMinorUnits = const Value.absent(),
    this.taxAmountMinorUnits = const Value.absent(),
    required int lineTotalMinorUnits,
    this.costPriceSnapshotMinorUnits = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saleId = Value(saleId),
       productId = Value(productId),
       quantity = Value(quantity),
       unitPriceMinorUnits = Value(unitPriceMinorUnits),
       lineTotalMinorUnits = Value(lineTotalMinorUnits);
  static Insertable<SaleLine> custom({
    Expression<String>? id,
    Expression<String>? saleId,
    Expression<String>? productId,
    Expression<int>? quantity,
    Expression<int>? unitPriceMinorUnits,
    Expression<int>? discountAmountMinorUnits,
    Expression<int>? taxAmountMinorUnits,
    Expression<int>? lineTotalMinorUnits,
    Expression<int>? costPriceSnapshotMinorUnits,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (unitPriceMinorUnits != null)
        'unit_price_minor_units': unitPriceMinorUnits,
      if (discountAmountMinorUnits != null)
        'discount_amount_minor_units': discountAmountMinorUnits,
      if (taxAmountMinorUnits != null)
        'tax_amount_minor_units': taxAmountMinorUnits,
      if (lineTotalMinorUnits != null)
        'line_total_minor_units': lineTotalMinorUnits,
      if (costPriceSnapshotMinorUnits != null)
        'cost_price_snapshot_minor_units': costPriceSnapshotMinorUnits,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleLinesCompanion copyWith({
    Value<String>? id,
    Value<String>? saleId,
    Value<String>? productId,
    Value<int>? quantity,
    Value<int>? unitPriceMinorUnits,
    Value<int>? discountAmountMinorUnits,
    Value<int>? taxAmountMinorUnits,
    Value<int>? lineTotalMinorUnits,
    Value<int>? costPriceSnapshotMinorUnits,
    Value<int>? rowid,
  }) {
    return SaleLinesCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPriceMinorUnits: unitPriceMinorUnits ?? this.unitPriceMinorUnits,
      discountAmountMinorUnits:
          discountAmountMinorUnits ?? this.discountAmountMinorUnits,
      taxAmountMinorUnits: taxAmountMinorUnits ?? this.taxAmountMinorUnits,
      lineTotalMinorUnits: lineTotalMinorUnits ?? this.lineTotalMinorUnits,
      costPriceSnapshotMinorUnits:
          costPriceSnapshotMinorUnits ?? this.costPriceSnapshotMinorUnits,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPriceMinorUnits.present) {
      map['unit_price_minor_units'] = Variable<int>(unitPriceMinorUnits.value);
    }
    if (discountAmountMinorUnits.present) {
      map['discount_amount_minor_units'] = Variable<int>(
        discountAmountMinorUnits.value,
      );
    }
    if (taxAmountMinorUnits.present) {
      map['tax_amount_minor_units'] = Variable<int>(taxAmountMinorUnits.value);
    }
    if (lineTotalMinorUnits.present) {
      map['line_total_minor_units'] = Variable<int>(lineTotalMinorUnits.value);
    }
    if (costPriceSnapshotMinorUnits.present) {
      map['cost_price_snapshot_minor_units'] = Variable<int>(
        costPriceSnapshotMinorUnits.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleLinesCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceMinorUnits: $unitPriceMinorUnits, ')
          ..write('discountAmountMinorUnits: $discountAmountMinorUnits, ')
          ..write('taxAmountMinorUnits: $taxAmountMinorUnits, ')
          ..write('lineTotalMinorUnits: $lineTotalMinorUnits, ')
          ..write('costPriceSnapshotMinorUnits: $costPriceSnapshotMinorUnits, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleReturnsTable extends SaleReturns
    with TableInfo<$SaleReturnsTable, SaleReturn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleReturnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _branchIdMeta = const VerificationMeta(
    'branchId',
  );
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
    'branch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalSaleIdMeta = const VerificationMeta(
    'originalSaleId',
  );
  @override
  late final GeneratedColumn<String> originalSaleId = GeneratedColumn<String>(
    'original_sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refundMethodMeta = const VerificationMeta(
    'refundMethod',
  );
  @override
  late final GeneratedColumn<String> refundMethod = GeneratedColumn<String>(
    'refund_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _journalEntryIdMeta = const VerificationMeta(
    'journalEntryId',
  );
  @override
  late final GeneratedColumn<String> journalEntryId = GeneratedColumn<String>(
    'journal_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _processedByUserIdMeta = const VerificationMeta(
    'processedByUserId',
  );
  @override
  late final GeneratedColumn<String> processedByUserId =
      GeneratedColumn<String>(
        'processed_by_user_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    branchId,
    originalSaleId,
    refundMethod,
    journalEntryId,
    processedByUserId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_returns';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleReturn> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(
        _branchIdMeta,
        branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('original_sale_id')) {
      context.handle(
        _originalSaleIdMeta,
        originalSaleId.isAcceptableOrUnknown(
          data['original_sale_id']!,
          _originalSaleIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalSaleIdMeta);
    }
    if (data.containsKey('refund_method')) {
      context.handle(
        _refundMethodMeta,
        refundMethod.isAcceptableOrUnknown(
          data['refund_method']!,
          _refundMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_refundMethodMeta);
    }
    if (data.containsKey('journal_entry_id')) {
      context.handle(
        _journalEntryIdMeta,
        journalEntryId.isAcceptableOrUnknown(
          data['journal_entry_id']!,
          _journalEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('processed_by_user_id')) {
      context.handle(
        _processedByUserIdMeta,
        processedByUserId.isAcceptableOrUnknown(
          data['processed_by_user_id']!,
          _processedByUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_processedByUserIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleReturn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleReturn(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      branchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_id'],
      )!,
      originalSaleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_sale_id'],
      )!,
      refundMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refund_method'],
      )!,
      journalEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}journal_entry_id'],
      ),
      processedByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}processed_by_user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SaleReturnsTable createAlias(String alias) {
    return $SaleReturnsTable(attachedDatabase, alias);
  }
}

class SaleReturn extends DataClass implements Insertable<SaleReturn> {
  final String id;
  final String storeId;
  final String branchId;
  final String originalSaleId;
  final String refundMethod;
  final String? journalEntryId;
  final String processedByUserId;
  final DateTime createdAt;
  const SaleReturn({
    required this.id,
    required this.storeId,
    required this.branchId,
    required this.originalSaleId,
    required this.refundMethod,
    this.journalEntryId,
    required this.processedByUserId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['branch_id'] = Variable<String>(branchId);
    map['original_sale_id'] = Variable<String>(originalSaleId);
    map['refund_method'] = Variable<String>(refundMethod);
    if (!nullToAbsent || journalEntryId != null) {
      map['journal_entry_id'] = Variable<String>(journalEntryId);
    }
    map['processed_by_user_id'] = Variable<String>(processedByUserId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SaleReturnsCompanion toCompanion(bool nullToAbsent) {
    return SaleReturnsCompanion(
      id: Value(id),
      storeId: Value(storeId),
      branchId: Value(branchId),
      originalSaleId: Value(originalSaleId),
      refundMethod: Value(refundMethod),
      journalEntryId: journalEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(journalEntryId),
      processedByUserId: Value(processedByUserId),
      createdAt: Value(createdAt),
    );
  }

  factory SaleReturn.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleReturn(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      branchId: serializer.fromJson<String>(json['branchId']),
      originalSaleId: serializer.fromJson<String>(json['originalSaleId']),
      refundMethod: serializer.fromJson<String>(json['refundMethod']),
      journalEntryId: serializer.fromJson<String?>(json['journalEntryId']),
      processedByUserId: serializer.fromJson<String>(json['processedByUserId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'branchId': serializer.toJson<String>(branchId),
      'originalSaleId': serializer.toJson<String>(originalSaleId),
      'refundMethod': serializer.toJson<String>(refundMethod),
      'journalEntryId': serializer.toJson<String?>(journalEntryId),
      'processedByUserId': serializer.toJson<String>(processedByUserId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SaleReturn copyWith({
    String? id,
    String? storeId,
    String? branchId,
    String? originalSaleId,
    String? refundMethod,
    Value<String?> journalEntryId = const Value.absent(),
    String? processedByUserId,
    DateTime? createdAt,
  }) => SaleReturn(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    branchId: branchId ?? this.branchId,
    originalSaleId: originalSaleId ?? this.originalSaleId,
    refundMethod: refundMethod ?? this.refundMethod,
    journalEntryId: journalEntryId.present
        ? journalEntryId.value
        : this.journalEntryId,
    processedByUserId: processedByUserId ?? this.processedByUserId,
    createdAt: createdAt ?? this.createdAt,
  );
  SaleReturn copyWithCompanion(SaleReturnsCompanion data) {
    return SaleReturn(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      originalSaleId: data.originalSaleId.present
          ? data.originalSaleId.value
          : this.originalSaleId,
      refundMethod: data.refundMethod.present
          ? data.refundMethod.value
          : this.refundMethod,
      journalEntryId: data.journalEntryId.present
          ? data.journalEntryId.value
          : this.journalEntryId,
      processedByUserId: data.processedByUserId.present
          ? data.processedByUserId.value
          : this.processedByUserId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleReturn(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('branchId: $branchId, ')
          ..write('originalSaleId: $originalSaleId, ')
          ..write('refundMethod: $refundMethod, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('processedByUserId: $processedByUserId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    branchId,
    originalSaleId,
    refundMethod,
    journalEntryId,
    processedByUserId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleReturn &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.branchId == this.branchId &&
          other.originalSaleId == this.originalSaleId &&
          other.refundMethod == this.refundMethod &&
          other.journalEntryId == this.journalEntryId &&
          other.processedByUserId == this.processedByUserId &&
          other.createdAt == this.createdAt);
}

class SaleReturnsCompanion extends UpdateCompanion<SaleReturn> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> branchId;
  final Value<String> originalSaleId;
  final Value<String> refundMethod;
  final Value<String?> journalEntryId;
  final Value<String> processedByUserId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SaleReturnsCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.branchId = const Value.absent(),
    this.originalSaleId = const Value.absent(),
    this.refundMethod = const Value.absent(),
    this.journalEntryId = const Value.absent(),
    this.processedByUserId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleReturnsCompanion.insert({
    required String id,
    required String storeId,
    required String branchId,
    required String originalSaleId,
    required String refundMethod,
    this.journalEntryId = const Value.absent(),
    required String processedByUserId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       branchId = Value(branchId),
       originalSaleId = Value(originalSaleId),
       refundMethod = Value(refundMethod),
       processedByUserId = Value(processedByUserId),
       createdAt = Value(createdAt);
  static Insertable<SaleReturn> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? branchId,
    Expression<String>? originalSaleId,
    Expression<String>? refundMethod,
    Expression<String>? journalEntryId,
    Expression<String>? processedByUserId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (branchId != null) 'branch_id': branchId,
      if (originalSaleId != null) 'original_sale_id': originalSaleId,
      if (refundMethod != null) 'refund_method': refundMethod,
      if (journalEntryId != null) 'journal_entry_id': journalEntryId,
      if (processedByUserId != null) 'processed_by_user_id': processedByUserId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleReturnsCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? branchId,
    Value<String>? originalSaleId,
    Value<String>? refundMethod,
    Value<String?>? journalEntryId,
    Value<String>? processedByUserId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SaleReturnsCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      branchId: branchId ?? this.branchId,
      originalSaleId: originalSaleId ?? this.originalSaleId,
      refundMethod: refundMethod ?? this.refundMethod,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      processedByUserId: processedByUserId ?? this.processedByUserId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (originalSaleId.present) {
      map['original_sale_id'] = Variable<String>(originalSaleId.value);
    }
    if (refundMethod.present) {
      map['refund_method'] = Variable<String>(refundMethod.value);
    }
    if (journalEntryId.present) {
      map['journal_entry_id'] = Variable<String>(journalEntryId.value);
    }
    if (processedByUserId.present) {
      map['processed_by_user_id'] = Variable<String>(processedByUserId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleReturnsCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('branchId: $branchId, ')
          ..write('originalSaleId: $originalSaleId, ')
          ..write('refundMethod: $refundMethod, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('processedByUserId: $processedByUserId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleReturnLinesTable extends SaleReturnLines
    with TableInfo<$SaleReturnLinesTable, SaleReturnLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleReturnLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleReturnIdMeta = const VerificationMeta(
    'saleReturnId',
  );
  @override
  late final GeneratedColumn<String> saleReturnId = GeneratedColumn<String>(
    'sale_return_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleLineIdMeta = const VerificationMeta(
    'saleLineId',
  );
  @override
  late final GeneratedColumn<String> saleLineId = GeneratedColumn<String>(
    'sale_line_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityReturnedMeta = const VerificationMeta(
    'quantityReturned',
  );
  @override
  late final GeneratedColumn<int> quantityReturned = GeneratedColumn<int>(
    'quantity_returned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refundAmountMinorUnitsMeta =
      const VerificationMeta('refundAmountMinorUnits');
  @override
  late final GeneratedColumn<int> refundAmountMinorUnits = GeneratedColumn<int>(
    'refund_amount_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saleReturnId,
    saleLineId,
    quantityReturned,
    refundAmountMinorUnits,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_return_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleReturnLine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sale_return_id')) {
      context.handle(
        _saleReturnIdMeta,
        saleReturnId.isAcceptableOrUnknown(
          data['sale_return_id']!,
          _saleReturnIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_saleReturnIdMeta);
    }
    if (data.containsKey('sale_line_id')) {
      context.handle(
        _saleLineIdMeta,
        saleLineId.isAcceptableOrUnknown(
          data['sale_line_id']!,
          _saleLineIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_saleLineIdMeta);
    }
    if (data.containsKey('quantity_returned')) {
      context.handle(
        _quantityReturnedMeta,
        quantityReturned.isAcceptableOrUnknown(
          data['quantity_returned']!,
          _quantityReturnedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityReturnedMeta);
    }
    if (data.containsKey('refund_amount_minor_units')) {
      context.handle(
        _refundAmountMinorUnitsMeta,
        refundAmountMinorUnits.isAcceptableOrUnknown(
          data['refund_amount_minor_units']!,
          _refundAmountMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_refundAmountMinorUnitsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleReturnLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleReturnLine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      saleReturnId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_return_id'],
      )!,
      saleLineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_line_id'],
      )!,
      quantityReturned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_returned'],
      )!,
      refundAmountMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}refund_amount_minor_units'],
      )!,
    );
  }

  @override
  $SaleReturnLinesTable createAlias(String alias) {
    return $SaleReturnLinesTable(attachedDatabase, alias);
  }
}

class SaleReturnLine extends DataClass implements Insertable<SaleReturnLine> {
  final String id;
  final String saleReturnId;
  final String saleLineId;
  final int quantityReturned;
  final int refundAmountMinorUnits;
  const SaleReturnLine({
    required this.id,
    required this.saleReturnId,
    required this.saleLineId,
    required this.quantityReturned,
    required this.refundAmountMinorUnits,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sale_return_id'] = Variable<String>(saleReturnId);
    map['sale_line_id'] = Variable<String>(saleLineId);
    map['quantity_returned'] = Variable<int>(quantityReturned);
    map['refund_amount_minor_units'] = Variable<int>(refundAmountMinorUnits);
    return map;
  }

  SaleReturnLinesCompanion toCompanion(bool nullToAbsent) {
    return SaleReturnLinesCompanion(
      id: Value(id),
      saleReturnId: Value(saleReturnId),
      saleLineId: Value(saleLineId),
      quantityReturned: Value(quantityReturned),
      refundAmountMinorUnits: Value(refundAmountMinorUnits),
    );
  }

  factory SaleReturnLine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleReturnLine(
      id: serializer.fromJson<String>(json['id']),
      saleReturnId: serializer.fromJson<String>(json['saleReturnId']),
      saleLineId: serializer.fromJson<String>(json['saleLineId']),
      quantityReturned: serializer.fromJson<int>(json['quantityReturned']),
      refundAmountMinorUnits: serializer.fromJson<int>(
        json['refundAmountMinorUnits'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saleReturnId': serializer.toJson<String>(saleReturnId),
      'saleLineId': serializer.toJson<String>(saleLineId),
      'quantityReturned': serializer.toJson<int>(quantityReturned),
      'refundAmountMinorUnits': serializer.toJson<int>(refundAmountMinorUnits),
    };
  }

  SaleReturnLine copyWith({
    String? id,
    String? saleReturnId,
    String? saleLineId,
    int? quantityReturned,
    int? refundAmountMinorUnits,
  }) => SaleReturnLine(
    id: id ?? this.id,
    saleReturnId: saleReturnId ?? this.saleReturnId,
    saleLineId: saleLineId ?? this.saleLineId,
    quantityReturned: quantityReturned ?? this.quantityReturned,
    refundAmountMinorUnits:
        refundAmountMinorUnits ?? this.refundAmountMinorUnits,
  );
  SaleReturnLine copyWithCompanion(SaleReturnLinesCompanion data) {
    return SaleReturnLine(
      id: data.id.present ? data.id.value : this.id,
      saleReturnId: data.saleReturnId.present
          ? data.saleReturnId.value
          : this.saleReturnId,
      saleLineId: data.saleLineId.present
          ? data.saleLineId.value
          : this.saleLineId,
      quantityReturned: data.quantityReturned.present
          ? data.quantityReturned.value
          : this.quantityReturned,
      refundAmountMinorUnits: data.refundAmountMinorUnits.present
          ? data.refundAmountMinorUnits.value
          : this.refundAmountMinorUnits,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleReturnLine(')
          ..write('id: $id, ')
          ..write('saleReturnId: $saleReturnId, ')
          ..write('saleLineId: $saleLineId, ')
          ..write('quantityReturned: $quantityReturned, ')
          ..write('refundAmountMinorUnits: $refundAmountMinorUnits')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    saleReturnId,
    saleLineId,
    quantityReturned,
    refundAmountMinorUnits,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleReturnLine &&
          other.id == this.id &&
          other.saleReturnId == this.saleReturnId &&
          other.saleLineId == this.saleLineId &&
          other.quantityReturned == this.quantityReturned &&
          other.refundAmountMinorUnits == this.refundAmountMinorUnits);
}

class SaleReturnLinesCompanion extends UpdateCompanion<SaleReturnLine> {
  final Value<String> id;
  final Value<String> saleReturnId;
  final Value<String> saleLineId;
  final Value<int> quantityReturned;
  final Value<int> refundAmountMinorUnits;
  final Value<int> rowid;
  const SaleReturnLinesCompanion({
    this.id = const Value.absent(),
    this.saleReturnId = const Value.absent(),
    this.saleLineId = const Value.absent(),
    this.quantityReturned = const Value.absent(),
    this.refundAmountMinorUnits = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleReturnLinesCompanion.insert({
    required String id,
    required String saleReturnId,
    required String saleLineId,
    required int quantityReturned,
    required int refundAmountMinorUnits,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saleReturnId = Value(saleReturnId),
       saleLineId = Value(saleLineId),
       quantityReturned = Value(quantityReturned),
       refundAmountMinorUnits = Value(refundAmountMinorUnits);
  static Insertable<SaleReturnLine> custom({
    Expression<String>? id,
    Expression<String>? saleReturnId,
    Expression<String>? saleLineId,
    Expression<int>? quantityReturned,
    Expression<int>? refundAmountMinorUnits,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleReturnId != null) 'sale_return_id': saleReturnId,
      if (saleLineId != null) 'sale_line_id': saleLineId,
      if (quantityReturned != null) 'quantity_returned': quantityReturned,
      if (refundAmountMinorUnits != null)
        'refund_amount_minor_units': refundAmountMinorUnits,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleReturnLinesCompanion copyWith({
    Value<String>? id,
    Value<String>? saleReturnId,
    Value<String>? saleLineId,
    Value<int>? quantityReturned,
    Value<int>? refundAmountMinorUnits,
    Value<int>? rowid,
  }) {
    return SaleReturnLinesCompanion(
      id: id ?? this.id,
      saleReturnId: saleReturnId ?? this.saleReturnId,
      saleLineId: saleLineId ?? this.saleLineId,
      quantityReturned: quantityReturned ?? this.quantityReturned,
      refundAmountMinorUnits:
          refundAmountMinorUnits ?? this.refundAmountMinorUnits,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saleReturnId.present) {
      map['sale_return_id'] = Variable<String>(saleReturnId.value);
    }
    if (saleLineId.present) {
      map['sale_line_id'] = Variable<String>(saleLineId.value);
    }
    if (quantityReturned.present) {
      map['quantity_returned'] = Variable<int>(quantityReturned.value);
    }
    if (refundAmountMinorUnits.present) {
      map['refund_amount_minor_units'] = Variable<int>(
        refundAmountMinorUnits.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleReturnLinesCompanion(')
          ..write('id: $id, ')
          ..write('saleReturnId: $saleReturnId, ')
          ..write('saleLineId: $saleLineId, ')
          ..write('quantityReturned: $quantityReturned, ')
          ..write('refundAmountMinorUnits: $refundAmountMinorUnits, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShiftsTable extends Shifts with TableInfo<$ShiftsTable, Shift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _branchIdMeta = const VerificationMeta(
    'branchId',
  );
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
    'branch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashierIdMeta = const VerificationMeta(
    'cashierId',
  );
  @override
  late final GeneratedColumn<String> cashierId = GeneratedColumn<String>(
    'cashier_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openingCashFloatMinorUnitsMeta =
      const VerificationMeta('openingCashFloatMinorUnits');
  @override
  late final GeneratedColumn<int> openingCashFloatMinorUnits =
      GeneratedColumn<int>(
        'opening_cash_float_minor_units',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _expectedCashAtCloseMinorUnitsMeta =
      const VerificationMeta('expectedCashAtCloseMinorUnits');
  @override
  late final GeneratedColumn<int> expectedCashAtCloseMinorUnits =
      GeneratedColumn<int>(
        'expected_cash_at_close_minor_units',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _countedCashAtCloseMinorUnitsMeta =
      const VerificationMeta('countedCashAtCloseMinorUnits');
  @override
  late final GeneratedColumn<int> countedCashAtCloseMinorUnits =
      GeneratedColumn<int>(
        'counted_cash_at_close_minor_units',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _discrepancyMinorUnitsMeta =
      const VerificationMeta('discrepancyMinorUnits');
  @override
  late final GeneratedColumn<int> discrepancyMinorUnits = GeneratedColumn<int>(
    'discrepancy_minor_units',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    branchId,
    cashierId,
    openedAt,
    closedAt,
    openingCashFloatMinorUnits,
    expectedCashAtCloseMinorUnits,
    countedCashAtCloseMinorUnits,
    discrepancyMinorUnits,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shifts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Shift> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(
        _branchIdMeta,
        branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('cashier_id')) {
      context.handle(
        _cashierIdMeta,
        cashierId.isAcceptableOrUnknown(data['cashier_id']!, _cashierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cashierIdMeta);
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_openedAtMeta);
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    if (data.containsKey('opening_cash_float_minor_units')) {
      context.handle(
        _openingCashFloatMinorUnitsMeta,
        openingCashFloatMinorUnits.isAcceptableOrUnknown(
          data['opening_cash_float_minor_units']!,
          _openingCashFloatMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('expected_cash_at_close_minor_units')) {
      context.handle(
        _expectedCashAtCloseMinorUnitsMeta,
        expectedCashAtCloseMinorUnits.isAcceptableOrUnknown(
          data['expected_cash_at_close_minor_units']!,
          _expectedCashAtCloseMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('counted_cash_at_close_minor_units')) {
      context.handle(
        _countedCashAtCloseMinorUnitsMeta,
        countedCashAtCloseMinorUnits.isAcceptableOrUnknown(
          data['counted_cash_at_close_minor_units']!,
          _countedCashAtCloseMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('discrepancy_minor_units')) {
      context.handle(
        _discrepancyMinorUnitsMeta,
        discrepancyMinorUnits.isAcceptableOrUnknown(
          data['discrepancy_minor_units']!,
          _discrepancyMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shift(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      branchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_id'],
      )!,
      cashierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cashier_id'],
      )!,
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      )!,
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      ),
      openingCashFloatMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_cash_float_minor_units'],
      )!,
      expectedCashAtCloseMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_cash_at_close_minor_units'],
      ),
      countedCashAtCloseMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}counted_cash_at_close_minor_units'],
      ),
      discrepancyMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discrepancy_minor_units'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $ShiftsTable createAlias(String alias) {
    return $ShiftsTable(attachedDatabase, alias);
  }
}

class Shift extends DataClass implements Insertable<Shift> {
  final String id;
  final String storeId;
  final String branchId;
  final String cashierId;
  final DateTime openedAt;
  final DateTime? closedAt;
  final int openingCashFloatMinorUnits;
  final int? expectedCashAtCloseMinorUnits;
  final int? countedCashAtCloseMinorUnits;
  final int? discrepancyMinorUnits;
  final String status;
  const Shift({
    required this.id,
    required this.storeId,
    required this.branchId,
    required this.cashierId,
    required this.openedAt,
    this.closedAt,
    required this.openingCashFloatMinorUnits,
    this.expectedCashAtCloseMinorUnits,
    this.countedCashAtCloseMinorUnits,
    this.discrepancyMinorUnits,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['branch_id'] = Variable<String>(branchId);
    map['cashier_id'] = Variable<String>(cashierId);
    map['opened_at'] = Variable<DateTime>(openedAt);
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    map['opening_cash_float_minor_units'] = Variable<int>(
      openingCashFloatMinorUnits,
    );
    if (!nullToAbsent || expectedCashAtCloseMinorUnits != null) {
      map['expected_cash_at_close_minor_units'] = Variable<int>(
        expectedCashAtCloseMinorUnits,
      );
    }
    if (!nullToAbsent || countedCashAtCloseMinorUnits != null) {
      map['counted_cash_at_close_minor_units'] = Variable<int>(
        countedCashAtCloseMinorUnits,
      );
    }
    if (!nullToAbsent || discrepancyMinorUnits != null) {
      map['discrepancy_minor_units'] = Variable<int>(discrepancyMinorUnits);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  ShiftsCompanion toCompanion(bool nullToAbsent) {
    return ShiftsCompanion(
      id: Value(id),
      storeId: Value(storeId),
      branchId: Value(branchId),
      cashierId: Value(cashierId),
      openedAt: Value(openedAt),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      openingCashFloatMinorUnits: Value(openingCashFloatMinorUnits),
      expectedCashAtCloseMinorUnits:
          expectedCashAtCloseMinorUnits == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedCashAtCloseMinorUnits),
      countedCashAtCloseMinorUnits:
          countedCashAtCloseMinorUnits == null && nullToAbsent
          ? const Value.absent()
          : Value(countedCashAtCloseMinorUnits),
      discrepancyMinorUnits: discrepancyMinorUnits == null && nullToAbsent
          ? const Value.absent()
          : Value(discrepancyMinorUnits),
      status: Value(status),
    );
  }

  factory Shift.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shift(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      branchId: serializer.fromJson<String>(json['branchId']),
      cashierId: serializer.fromJson<String>(json['cashierId']),
      openedAt: serializer.fromJson<DateTime>(json['openedAt']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
      openingCashFloatMinorUnits: serializer.fromJson<int>(
        json['openingCashFloatMinorUnits'],
      ),
      expectedCashAtCloseMinorUnits: serializer.fromJson<int?>(
        json['expectedCashAtCloseMinorUnits'],
      ),
      countedCashAtCloseMinorUnits: serializer.fromJson<int?>(
        json['countedCashAtCloseMinorUnits'],
      ),
      discrepancyMinorUnits: serializer.fromJson<int?>(
        json['discrepancyMinorUnits'],
      ),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'branchId': serializer.toJson<String>(branchId),
      'cashierId': serializer.toJson<String>(cashierId),
      'openedAt': serializer.toJson<DateTime>(openedAt),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
      'openingCashFloatMinorUnits': serializer.toJson<int>(
        openingCashFloatMinorUnits,
      ),
      'expectedCashAtCloseMinorUnits': serializer.toJson<int?>(
        expectedCashAtCloseMinorUnits,
      ),
      'countedCashAtCloseMinorUnits': serializer.toJson<int?>(
        countedCashAtCloseMinorUnits,
      ),
      'discrepancyMinorUnits': serializer.toJson<int?>(discrepancyMinorUnits),
      'status': serializer.toJson<String>(status),
    };
  }

  Shift copyWith({
    String? id,
    String? storeId,
    String? branchId,
    String? cashierId,
    DateTime? openedAt,
    Value<DateTime?> closedAt = const Value.absent(),
    int? openingCashFloatMinorUnits,
    Value<int?> expectedCashAtCloseMinorUnits = const Value.absent(),
    Value<int?> countedCashAtCloseMinorUnits = const Value.absent(),
    Value<int?> discrepancyMinorUnits = const Value.absent(),
    String? status,
  }) => Shift(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    branchId: branchId ?? this.branchId,
    cashierId: cashierId ?? this.cashierId,
    openedAt: openedAt ?? this.openedAt,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
    openingCashFloatMinorUnits:
        openingCashFloatMinorUnits ?? this.openingCashFloatMinorUnits,
    expectedCashAtCloseMinorUnits: expectedCashAtCloseMinorUnits.present
        ? expectedCashAtCloseMinorUnits.value
        : this.expectedCashAtCloseMinorUnits,
    countedCashAtCloseMinorUnits: countedCashAtCloseMinorUnits.present
        ? countedCashAtCloseMinorUnits.value
        : this.countedCashAtCloseMinorUnits,
    discrepancyMinorUnits: discrepancyMinorUnits.present
        ? discrepancyMinorUnits.value
        : this.discrepancyMinorUnits,
    status: status ?? this.status,
  );
  Shift copyWithCompanion(ShiftsCompanion data) {
    return Shift(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      cashierId: data.cashierId.present ? data.cashierId.value : this.cashierId,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      openingCashFloatMinorUnits: data.openingCashFloatMinorUnits.present
          ? data.openingCashFloatMinorUnits.value
          : this.openingCashFloatMinorUnits,
      expectedCashAtCloseMinorUnits: data.expectedCashAtCloseMinorUnits.present
          ? data.expectedCashAtCloseMinorUnits.value
          : this.expectedCashAtCloseMinorUnits,
      countedCashAtCloseMinorUnits: data.countedCashAtCloseMinorUnits.present
          ? data.countedCashAtCloseMinorUnits.value
          : this.countedCashAtCloseMinorUnits,
      discrepancyMinorUnits: data.discrepancyMinorUnits.present
          ? data.discrepancyMinorUnits.value
          : this.discrepancyMinorUnits,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shift(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('branchId: $branchId, ')
          ..write('cashierId: $cashierId, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('openingCashFloatMinorUnits: $openingCashFloatMinorUnits, ')
          ..write(
            'expectedCashAtCloseMinorUnits: $expectedCashAtCloseMinorUnits, ',
          )
          ..write(
            'countedCashAtCloseMinorUnits: $countedCashAtCloseMinorUnits, ',
          )
          ..write('discrepancyMinorUnits: $discrepancyMinorUnits, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    branchId,
    cashierId,
    openedAt,
    closedAt,
    openingCashFloatMinorUnits,
    expectedCashAtCloseMinorUnits,
    countedCashAtCloseMinorUnits,
    discrepancyMinorUnits,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shift &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.branchId == this.branchId &&
          other.cashierId == this.cashierId &&
          other.openedAt == this.openedAt &&
          other.closedAt == this.closedAt &&
          other.openingCashFloatMinorUnits == this.openingCashFloatMinorUnits &&
          other.expectedCashAtCloseMinorUnits ==
              this.expectedCashAtCloseMinorUnits &&
          other.countedCashAtCloseMinorUnits ==
              this.countedCashAtCloseMinorUnits &&
          other.discrepancyMinorUnits == this.discrepancyMinorUnits &&
          other.status == this.status);
}

class ShiftsCompanion extends UpdateCompanion<Shift> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> branchId;
  final Value<String> cashierId;
  final Value<DateTime> openedAt;
  final Value<DateTime?> closedAt;
  final Value<int> openingCashFloatMinorUnits;
  final Value<int?> expectedCashAtCloseMinorUnits;
  final Value<int?> countedCashAtCloseMinorUnits;
  final Value<int?> discrepancyMinorUnits;
  final Value<String> status;
  final Value<int> rowid;
  const ShiftsCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.branchId = const Value.absent(),
    this.cashierId = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.openingCashFloatMinorUnits = const Value.absent(),
    this.expectedCashAtCloseMinorUnits = const Value.absent(),
    this.countedCashAtCloseMinorUnits = const Value.absent(),
    this.discrepancyMinorUnits = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShiftsCompanion.insert({
    required String id,
    required String storeId,
    required String branchId,
    required String cashierId,
    required DateTime openedAt,
    this.closedAt = const Value.absent(),
    this.openingCashFloatMinorUnits = const Value.absent(),
    this.expectedCashAtCloseMinorUnits = const Value.absent(),
    this.countedCashAtCloseMinorUnits = const Value.absent(),
    this.discrepancyMinorUnits = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       branchId = Value(branchId),
       cashierId = Value(cashierId),
       openedAt = Value(openedAt);
  static Insertable<Shift> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? branchId,
    Expression<String>? cashierId,
    Expression<DateTime>? openedAt,
    Expression<DateTime>? closedAt,
    Expression<int>? openingCashFloatMinorUnits,
    Expression<int>? expectedCashAtCloseMinorUnits,
    Expression<int>? countedCashAtCloseMinorUnits,
    Expression<int>? discrepancyMinorUnits,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (branchId != null) 'branch_id': branchId,
      if (cashierId != null) 'cashier_id': cashierId,
      if (openedAt != null) 'opened_at': openedAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (openingCashFloatMinorUnits != null)
        'opening_cash_float_minor_units': openingCashFloatMinorUnits,
      if (expectedCashAtCloseMinorUnits != null)
        'expected_cash_at_close_minor_units': expectedCashAtCloseMinorUnits,
      if (countedCashAtCloseMinorUnits != null)
        'counted_cash_at_close_minor_units': countedCashAtCloseMinorUnits,
      if (discrepancyMinorUnits != null)
        'discrepancy_minor_units': discrepancyMinorUnits,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShiftsCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? branchId,
    Value<String>? cashierId,
    Value<DateTime>? openedAt,
    Value<DateTime?>? closedAt,
    Value<int>? openingCashFloatMinorUnits,
    Value<int?>? expectedCashAtCloseMinorUnits,
    Value<int?>? countedCashAtCloseMinorUnits,
    Value<int?>? discrepancyMinorUnits,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return ShiftsCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      branchId: branchId ?? this.branchId,
      cashierId: cashierId ?? this.cashierId,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      openingCashFloatMinorUnits:
          openingCashFloatMinorUnits ?? this.openingCashFloatMinorUnits,
      expectedCashAtCloseMinorUnits:
          expectedCashAtCloseMinorUnits ?? this.expectedCashAtCloseMinorUnits,
      countedCashAtCloseMinorUnits:
          countedCashAtCloseMinorUnits ?? this.countedCashAtCloseMinorUnits,
      discrepancyMinorUnits:
          discrepancyMinorUnits ?? this.discrepancyMinorUnits,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (cashierId.present) {
      map['cashier_id'] = Variable<String>(cashierId.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (openingCashFloatMinorUnits.present) {
      map['opening_cash_float_minor_units'] = Variable<int>(
        openingCashFloatMinorUnits.value,
      );
    }
    if (expectedCashAtCloseMinorUnits.present) {
      map['expected_cash_at_close_minor_units'] = Variable<int>(
        expectedCashAtCloseMinorUnits.value,
      );
    }
    if (countedCashAtCloseMinorUnits.present) {
      map['counted_cash_at_close_minor_units'] = Variable<int>(
        countedCashAtCloseMinorUnits.value,
      );
    }
    if (discrepancyMinorUnits.present) {
      map['discrepancy_minor_units'] = Variable<int>(
        discrepancyMinorUnits.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShiftsCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('branchId: $branchId, ')
          ..write('cashierId: $cashierId, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('openingCashFloatMinorUnits: $openingCashFloatMinorUnits, ')
          ..write(
            'expectedCashAtCloseMinorUnits: $expectedCashAtCloseMinorUnits, ',
          )
          ..write(
            'countedCashAtCloseMinorUnits: $countedCashAtCloseMinorUnits, ',
          )
          ..write('discrepancyMinorUnits: $discrepancyMinorUnits, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTableTable extends AppSettingsTable
    with TableInfo<$AppSettingsTableTable, AppSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultLanguageMeta = const VerificationMeta(
    'defaultLanguage',
  );
  @override
  late final GeneratedColumn<String> defaultLanguage = GeneratedColumn<String>(
    'default_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('USD'),
  );
  static const VerificationMeta _currencySymbolMeta = const VerificationMeta(
    'currencySymbol',
  );
  @override
  late final GeneratedColumn<String> currencySymbol = GeneratedColumn<String>(
    'currency_symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('\$'),
  );
  static const VerificationMeta _defaultVatRatePercentMeta =
      const VerificationMeta('defaultVatRatePercent');
  @override
  late final GeneratedColumn<double> defaultVatRatePercent =
      GeneratedColumn<double>(
        'default_vat_rate_percent',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _printerConfigJsonMeta = const VerificationMeta(
    'printerConfigJson',
  );
  @override
  late final GeneratedColumn<String> printerConfigJson =
      GeneratedColumn<String>(
        'printer_config_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _autoBackupEnabledMeta = const VerificationMeta(
    'autoBackupEnabled',
  );
  @override
  late final GeneratedColumn<bool> autoBackupEnabled = GeneratedColumn<bool>(
    'auto_backup_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_backup_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _autoBackupTimeOfDayMeta =
      const VerificationMeta('autoBackupTimeOfDay');
  @override
  late final GeneratedColumn<String> autoBackupTimeOfDay =
      GeneratedColumn<String>(
        'auto_backup_time_of_day',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('22:00'),
      );
  static const VerificationMeta _autoBackupFolderPathMeta =
      const VerificationMeta('autoBackupFolderPath');
  @override
  late final GeneratedColumn<String> autoBackupFolderPath =
      GeneratedColumn<String>(
        'auto_backup_folder_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lowStockThresholdDefaultMeta =
      const VerificationMeta('lowStockThresholdDefault');
  @override
  late final GeneratedColumn<int> lowStockThresholdDefault =
      GeneratedColumn<int>(
        'low_stock_threshold_default',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(5),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    defaultLanguage,
    themeMode,
    currencyCode,
    currencySymbol,
    defaultVatRatePercent,
    printerConfigJson,
    autoBackupEnabled,
    autoBackupTimeOfDay,
    autoBackupFolderPath,
    lowStockThresholdDefault,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('default_language')) {
      context.handle(
        _defaultLanguageMeta,
        defaultLanguage.isAcceptableOrUnknown(
          data['default_language']!,
          _defaultLanguageMeta,
        ),
      );
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('currency_symbol')) {
      context.handle(
        _currencySymbolMeta,
        currencySymbol.isAcceptableOrUnknown(
          data['currency_symbol']!,
          _currencySymbolMeta,
        ),
      );
    }
    if (data.containsKey('default_vat_rate_percent')) {
      context.handle(
        _defaultVatRatePercentMeta,
        defaultVatRatePercent.isAcceptableOrUnknown(
          data['default_vat_rate_percent']!,
          _defaultVatRatePercentMeta,
        ),
      );
    }
    if (data.containsKey('printer_config_json')) {
      context.handle(
        _printerConfigJsonMeta,
        printerConfigJson.isAcceptableOrUnknown(
          data['printer_config_json']!,
          _printerConfigJsonMeta,
        ),
      );
    }
    if (data.containsKey('auto_backup_enabled')) {
      context.handle(
        _autoBackupEnabledMeta,
        autoBackupEnabled.isAcceptableOrUnknown(
          data['auto_backup_enabled']!,
          _autoBackupEnabledMeta,
        ),
      );
    }
    if (data.containsKey('auto_backup_time_of_day')) {
      context.handle(
        _autoBackupTimeOfDayMeta,
        autoBackupTimeOfDay.isAcceptableOrUnknown(
          data['auto_backup_time_of_day']!,
          _autoBackupTimeOfDayMeta,
        ),
      );
    }
    if (data.containsKey('auto_backup_folder_path')) {
      context.handle(
        _autoBackupFolderPathMeta,
        autoBackupFolderPath.isAcceptableOrUnknown(
          data['auto_backup_folder_path']!,
          _autoBackupFolderPathMeta,
        ),
      );
    }
    if (data.containsKey('low_stock_threshold_default')) {
      context.handle(
        _lowStockThresholdDefaultMeta,
        lowStockThresholdDefault.isAcceptableOrUnknown(
          data['low_stock_threshold_default']!,
          _lowStockThresholdDefaultMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      defaultLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_language'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      currencySymbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_symbol'],
      )!,
      defaultVatRatePercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_vat_rate_percent'],
      )!,
      printerConfigJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}printer_config_json'],
      )!,
      autoBackupEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_backup_enabled'],
      )!,
      autoBackupTimeOfDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auto_backup_time_of_day'],
      )!,
      autoBackupFolderPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auto_backup_folder_path'],
      ),
      lowStockThresholdDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}low_stock_threshold_default'],
      )!,
    );
  }

  @override
  $AppSettingsTableTable createAlias(String alias) {
    return $AppSettingsTableTable(attachedDatabase, alias);
  }
}

class AppSettingsTableData extends DataClass
    implements Insertable<AppSettingsTableData> {
  final String id;
  final String storeId;
  final String defaultLanguage;
  final String themeMode;
  final String currencyCode;
  final String currencySymbol;
  final double defaultVatRatePercent;

  /// JSON-encoded PrinterConfig (driver type + connection details + paper width).
  final String printerConfigJson;
  final bool autoBackupEnabled;
  final String autoBackupTimeOfDay;
  final String? autoBackupFolderPath;
  final int lowStockThresholdDefault;
  const AppSettingsTableData({
    required this.id,
    required this.storeId,
    required this.defaultLanguage,
    required this.themeMode,
    required this.currencyCode,
    required this.currencySymbol,
    required this.defaultVatRatePercent,
    required this.printerConfigJson,
    required this.autoBackupEnabled,
    required this.autoBackupTimeOfDay,
    this.autoBackupFolderPath,
    required this.lowStockThresholdDefault,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['default_language'] = Variable<String>(defaultLanguage);
    map['theme_mode'] = Variable<String>(themeMode);
    map['currency_code'] = Variable<String>(currencyCode);
    map['currency_symbol'] = Variable<String>(currencySymbol);
    map['default_vat_rate_percent'] = Variable<double>(defaultVatRatePercent);
    map['printer_config_json'] = Variable<String>(printerConfigJson);
    map['auto_backup_enabled'] = Variable<bool>(autoBackupEnabled);
    map['auto_backup_time_of_day'] = Variable<String>(autoBackupTimeOfDay);
    if (!nullToAbsent || autoBackupFolderPath != null) {
      map['auto_backup_folder_path'] = Variable<String>(autoBackupFolderPath);
    }
    map['low_stock_threshold_default'] = Variable<int>(
      lowStockThresholdDefault,
    );
    return map;
  }

  AppSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsTableCompanion(
      id: Value(id),
      storeId: Value(storeId),
      defaultLanguage: Value(defaultLanguage),
      themeMode: Value(themeMode),
      currencyCode: Value(currencyCode),
      currencySymbol: Value(currencySymbol),
      defaultVatRatePercent: Value(defaultVatRatePercent),
      printerConfigJson: Value(printerConfigJson),
      autoBackupEnabled: Value(autoBackupEnabled),
      autoBackupTimeOfDay: Value(autoBackupTimeOfDay),
      autoBackupFolderPath: autoBackupFolderPath == null && nullToAbsent
          ? const Value.absent()
          : Value(autoBackupFolderPath),
      lowStockThresholdDefault: Value(lowStockThresholdDefault),
    );
  }

  factory AppSettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsTableData(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      defaultLanguage: serializer.fromJson<String>(json['defaultLanguage']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      currencySymbol: serializer.fromJson<String>(json['currencySymbol']),
      defaultVatRatePercent: serializer.fromJson<double>(
        json['defaultVatRatePercent'],
      ),
      printerConfigJson: serializer.fromJson<String>(json['printerConfigJson']),
      autoBackupEnabled: serializer.fromJson<bool>(json['autoBackupEnabled']),
      autoBackupTimeOfDay: serializer.fromJson<String>(
        json['autoBackupTimeOfDay'],
      ),
      autoBackupFolderPath: serializer.fromJson<String?>(
        json['autoBackupFolderPath'],
      ),
      lowStockThresholdDefault: serializer.fromJson<int>(
        json['lowStockThresholdDefault'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'defaultLanguage': serializer.toJson<String>(defaultLanguage),
      'themeMode': serializer.toJson<String>(themeMode),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'currencySymbol': serializer.toJson<String>(currencySymbol),
      'defaultVatRatePercent': serializer.toJson<double>(defaultVatRatePercent),
      'printerConfigJson': serializer.toJson<String>(printerConfigJson),
      'autoBackupEnabled': serializer.toJson<bool>(autoBackupEnabled),
      'autoBackupTimeOfDay': serializer.toJson<String>(autoBackupTimeOfDay),
      'autoBackupFolderPath': serializer.toJson<String?>(autoBackupFolderPath),
      'lowStockThresholdDefault': serializer.toJson<int>(
        lowStockThresholdDefault,
      ),
    };
  }

  AppSettingsTableData copyWith({
    String? id,
    String? storeId,
    String? defaultLanguage,
    String? themeMode,
    String? currencyCode,
    String? currencySymbol,
    double? defaultVatRatePercent,
    String? printerConfigJson,
    bool? autoBackupEnabled,
    String? autoBackupTimeOfDay,
    Value<String?> autoBackupFolderPath = const Value.absent(),
    int? lowStockThresholdDefault,
  }) => AppSettingsTableData(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    defaultLanguage: defaultLanguage ?? this.defaultLanguage,
    themeMode: themeMode ?? this.themeMode,
    currencyCode: currencyCode ?? this.currencyCode,
    currencySymbol: currencySymbol ?? this.currencySymbol,
    defaultVatRatePercent: defaultVatRatePercent ?? this.defaultVatRatePercent,
    printerConfigJson: printerConfigJson ?? this.printerConfigJson,
    autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
    autoBackupTimeOfDay: autoBackupTimeOfDay ?? this.autoBackupTimeOfDay,
    autoBackupFolderPath: autoBackupFolderPath.present
        ? autoBackupFolderPath.value
        : this.autoBackupFolderPath,
    lowStockThresholdDefault:
        lowStockThresholdDefault ?? this.lowStockThresholdDefault,
  );
  AppSettingsTableData copyWithCompanion(AppSettingsTableCompanion data) {
    return AppSettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      defaultLanguage: data.defaultLanguage.present
          ? data.defaultLanguage.value
          : this.defaultLanguage,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      currencySymbol: data.currencySymbol.present
          ? data.currencySymbol.value
          : this.currencySymbol,
      defaultVatRatePercent: data.defaultVatRatePercent.present
          ? data.defaultVatRatePercent.value
          : this.defaultVatRatePercent,
      printerConfigJson: data.printerConfigJson.present
          ? data.printerConfigJson.value
          : this.printerConfigJson,
      autoBackupEnabled: data.autoBackupEnabled.present
          ? data.autoBackupEnabled.value
          : this.autoBackupEnabled,
      autoBackupTimeOfDay: data.autoBackupTimeOfDay.present
          ? data.autoBackupTimeOfDay.value
          : this.autoBackupTimeOfDay,
      autoBackupFolderPath: data.autoBackupFolderPath.present
          ? data.autoBackupFolderPath.value
          : this.autoBackupFolderPath,
      lowStockThresholdDefault: data.lowStockThresholdDefault.present
          ? data.lowStockThresholdDefault.value
          : this.lowStockThresholdDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableData(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('defaultLanguage: $defaultLanguage, ')
          ..write('themeMode: $themeMode, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('defaultVatRatePercent: $defaultVatRatePercent, ')
          ..write('printerConfigJson: $printerConfigJson, ')
          ..write('autoBackupEnabled: $autoBackupEnabled, ')
          ..write('autoBackupTimeOfDay: $autoBackupTimeOfDay, ')
          ..write('autoBackupFolderPath: $autoBackupFolderPath, ')
          ..write('lowStockThresholdDefault: $lowStockThresholdDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    defaultLanguage,
    themeMode,
    currencyCode,
    currencySymbol,
    defaultVatRatePercent,
    printerConfigJson,
    autoBackupEnabled,
    autoBackupTimeOfDay,
    autoBackupFolderPath,
    lowStockThresholdDefault,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsTableData &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.defaultLanguage == this.defaultLanguage &&
          other.themeMode == this.themeMode &&
          other.currencyCode == this.currencyCode &&
          other.currencySymbol == this.currencySymbol &&
          other.defaultVatRatePercent == this.defaultVatRatePercent &&
          other.printerConfigJson == this.printerConfigJson &&
          other.autoBackupEnabled == this.autoBackupEnabled &&
          other.autoBackupTimeOfDay == this.autoBackupTimeOfDay &&
          other.autoBackupFolderPath == this.autoBackupFolderPath &&
          other.lowStockThresholdDefault == this.lowStockThresholdDefault);
}

class AppSettingsTableCompanion extends UpdateCompanion<AppSettingsTableData> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> defaultLanguage;
  final Value<String> themeMode;
  final Value<String> currencyCode;
  final Value<String> currencySymbol;
  final Value<double> defaultVatRatePercent;
  final Value<String> printerConfigJson;
  final Value<bool> autoBackupEnabled;
  final Value<String> autoBackupTimeOfDay;
  final Value<String?> autoBackupFolderPath;
  final Value<int> lowStockThresholdDefault;
  final Value<int> rowid;
  const AppSettingsTableCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.defaultLanguage = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.defaultVatRatePercent = const Value.absent(),
    this.printerConfigJson = const Value.absent(),
    this.autoBackupEnabled = const Value.absent(),
    this.autoBackupTimeOfDay = const Value.absent(),
    this.autoBackupFolderPath = const Value.absent(),
    this.lowStockThresholdDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsTableCompanion.insert({
    required String id,
    required String storeId,
    this.defaultLanguage = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.defaultVatRatePercent = const Value.absent(),
    this.printerConfigJson = const Value.absent(),
    this.autoBackupEnabled = const Value.absent(),
    this.autoBackupTimeOfDay = const Value.absent(),
    this.autoBackupFolderPath = const Value.absent(),
    this.lowStockThresholdDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId);
  static Insertable<AppSettingsTableData> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? defaultLanguage,
    Expression<String>? themeMode,
    Expression<String>? currencyCode,
    Expression<String>? currencySymbol,
    Expression<double>? defaultVatRatePercent,
    Expression<String>? printerConfigJson,
    Expression<bool>? autoBackupEnabled,
    Expression<String>? autoBackupTimeOfDay,
    Expression<String>? autoBackupFolderPath,
    Expression<int>? lowStockThresholdDefault,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (defaultLanguage != null) 'default_language': defaultLanguage,
      if (themeMode != null) 'theme_mode': themeMode,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (currencySymbol != null) 'currency_symbol': currencySymbol,
      if (defaultVatRatePercent != null)
        'default_vat_rate_percent': defaultVatRatePercent,
      if (printerConfigJson != null) 'printer_config_json': printerConfigJson,
      if (autoBackupEnabled != null) 'auto_backup_enabled': autoBackupEnabled,
      if (autoBackupTimeOfDay != null)
        'auto_backup_time_of_day': autoBackupTimeOfDay,
      if (autoBackupFolderPath != null)
        'auto_backup_folder_path': autoBackupFolderPath,
      if (lowStockThresholdDefault != null)
        'low_stock_threshold_default': lowStockThresholdDefault,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? defaultLanguage,
    Value<String>? themeMode,
    Value<String>? currencyCode,
    Value<String>? currencySymbol,
    Value<double>? defaultVatRatePercent,
    Value<String>? printerConfigJson,
    Value<bool>? autoBackupEnabled,
    Value<String>? autoBackupTimeOfDay,
    Value<String?>? autoBackupFolderPath,
    Value<int>? lowStockThresholdDefault,
    Value<int>? rowid,
  }) {
    return AppSettingsTableCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      defaultLanguage: defaultLanguage ?? this.defaultLanguage,
      themeMode: themeMode ?? this.themeMode,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      defaultVatRatePercent:
          defaultVatRatePercent ?? this.defaultVatRatePercent,
      printerConfigJson: printerConfigJson ?? this.printerConfigJson,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      autoBackupTimeOfDay: autoBackupTimeOfDay ?? this.autoBackupTimeOfDay,
      autoBackupFolderPath: autoBackupFolderPath ?? this.autoBackupFolderPath,
      lowStockThresholdDefault:
          lowStockThresholdDefault ?? this.lowStockThresholdDefault,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (defaultLanguage.present) {
      map['default_language'] = Variable<String>(defaultLanguage.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (currencySymbol.present) {
      map['currency_symbol'] = Variable<String>(currencySymbol.value);
    }
    if (defaultVatRatePercent.present) {
      map['default_vat_rate_percent'] = Variable<double>(
        defaultVatRatePercent.value,
      );
    }
    if (printerConfigJson.present) {
      map['printer_config_json'] = Variable<String>(printerConfigJson.value);
    }
    if (autoBackupEnabled.present) {
      map['auto_backup_enabled'] = Variable<bool>(autoBackupEnabled.value);
    }
    if (autoBackupTimeOfDay.present) {
      map['auto_backup_time_of_day'] = Variable<String>(
        autoBackupTimeOfDay.value,
      );
    }
    if (autoBackupFolderPath.present) {
      map['auto_backup_folder_path'] = Variable<String>(
        autoBackupFolderPath.value,
      );
    }
    if (lowStockThresholdDefault.present) {
      map['low_stock_threshold_default'] = Variable<int>(
        lowStockThresholdDefault.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('defaultLanguage: $defaultLanguage, ')
          ..write('themeMode: $themeMode, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('defaultVatRatePercent: $defaultVatRatePercent, ')
          ..write('printerConfigJson: $printerConfigJson, ')
          ..write('autoBackupEnabled: $autoBackupEnabled, ')
          ..write('autoBackupTimeOfDay: $autoBackupTimeOfDay, ')
          ..write('autoBackupFolderPath: $autoBackupFolderPath, ')
          ..write('lowStockThresholdDefault: $lowStockThresholdDefault, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BackupLogsTable extends BackupLogs
    with TableInfo<$BackupLogsTable, BackupLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    filePath,
    sizeBytes,
    type,
    status,
    errorMessage,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backup_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<BackupLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BackupLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BackupLogsTable createAlias(String alias) {
    return $BackupLogsTable(attachedDatabase, alias);
  }
}

class BackupLog extends DataClass implements Insertable<BackupLog> {
  final String id;
  final String storeId;
  final String filePath;
  final int sizeBytes;
  final String type;
  final String status;
  final String? errorMessage;
  final DateTime createdAt;
  const BackupLog({
    required this.id,
    required this.storeId,
    required this.filePath,
    required this.sizeBytes,
    required this.type,
    required this.status,
    this.errorMessage,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['file_path'] = Variable<String>(filePath);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BackupLogsCompanion toCompanion(bool nullToAbsent) {
    return BackupLogsCompanion(
      id: Value(id),
      storeId: Value(storeId),
      filePath: Value(filePath),
      sizeBytes: Value(sizeBytes),
      type: Value(type),
      status: Value(status),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: Value(createdAt),
    );
  }

  factory BackupLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupLog(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'filePath': serializer.toJson<String>(filePath),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BackupLog copyWith({
    String? id,
    String? storeId,
    String? filePath,
    int? sizeBytes,
    String? type,
    String? status,
    Value<String?> errorMessage = const Value.absent(),
    DateTime? createdAt,
  }) => BackupLog(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    filePath: filePath ?? this.filePath,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    type: type ?? this.type,
    status: status ?? this.status,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    createdAt: createdAt ?? this.createdAt,
  );
  BackupLog copyWithCompanion(BackupLogsCompanion data) {
    return BackupLog(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupLog(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('filePath: $filePath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    filePath,
    sizeBytes,
    type,
    status,
    errorMessage,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupLog &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.filePath == this.filePath &&
          other.sizeBytes == this.sizeBytes &&
          other.type == this.type &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt);
}

class BackupLogsCompanion extends UpdateCompanion<BackupLog> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> filePath;
  final Value<int> sizeBytes;
  final Value<String> type;
  final Value<String> status;
  final Value<String?> errorMessage;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BackupLogsCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BackupLogsCompanion.insert({
    required String id,
    required String storeId,
    required String filePath,
    this.sizeBytes = const Value.absent(),
    required String type,
    required String status,
    this.errorMessage = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       filePath = Value(filePath),
       type = Value(type),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<BackupLog> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? filePath,
    Expression<int>? sizeBytes,
    Expression<String>? type,
    Expression<String>? status,
    Expression<String>? errorMessage,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (filePath != null) 'file_path': filePath,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BackupLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? filePath,
    Value<int>? sizeBytes,
    Value<String>? type,
    Value<String>? status,
    Value<String?>? errorMessage,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BackupLogsCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      filePath: filePath ?? this.filePath,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      type: type ?? this.type,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupLogsCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('filePath: $filePath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogsTable extends AuditLogs
    with TableInfo<$AuditLogsTable, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _beforeValueJsonMeta = const VerificationMeta(
    'beforeValueJson',
  );
  @override
  late final GeneratedColumn<String> beforeValueJson = GeneratedColumn<String>(
    'before_value_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _afterValueJsonMeta = const VerificationMeta(
    'afterValueJson',
  );
  @override
  late final GeneratedColumn<String> afterValueJson = GeneratedColumn<String>(
    'after_value_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    userId,
    action,
    entityType,
    entityId,
    beforeValueJson,
    afterValueJson,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    }
    if (data.containsKey('before_value_json')) {
      context.handle(
        _beforeValueJsonMeta,
        beforeValueJson.isAcceptableOrUnknown(
          data['before_value_json']!,
          _beforeValueJsonMeta,
        ),
      );
    }
    if (data.containsKey('after_value_json')) {
      context.handle(
        _afterValueJsonMeta,
        afterValueJson.isAcceptableOrUnknown(
          data['after_value_json']!,
          _afterValueJsonMeta,
        ),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      ),
      beforeValueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}before_value_json'],
      ),
      afterValueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}after_value_json'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final String id;
  final String storeId;
  final String userId;
  final String action;
  final String entityType;
  final String? entityId;
  final String? beforeValueJson;
  final String? afterValueJson;
  final DateTime timestamp;
  const AuditLog({
    required this.id,
    required this.storeId,
    required this.userId,
    required this.action,
    required this.entityType,
    this.entityId,
    this.beforeValueJson,
    this.afterValueJson,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['user_id'] = Variable<String>(userId);
    map['action'] = Variable<String>(action);
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<String>(entityId);
    }
    if (!nullToAbsent || beforeValueJson != null) {
      map['before_value_json'] = Variable<String>(beforeValueJson);
    }
    if (!nullToAbsent || afterValueJson != null) {
      map['after_value_json'] = Variable<String>(afterValueJson);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      id: Value(id),
      storeId: Value(storeId),
      userId: Value(userId),
      action: Value(action),
      entityType: Value(entityType),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      beforeValueJson: beforeValueJson == null && nullToAbsent
          ? const Value.absent()
          : Value(beforeValueJson),
      afterValueJson: afterValueJson == null && nullToAbsent
          ? const Value.absent()
          : Value(afterValueJson),
      timestamp: Value(timestamp),
    );
  }

  factory AuditLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      userId: serializer.fromJson<String>(json['userId']),
      action: serializer.fromJson<String>(json['action']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String?>(json['entityId']),
      beforeValueJson: serializer.fromJson<String?>(json['beforeValueJson']),
      afterValueJson: serializer.fromJson<String?>(json['afterValueJson']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'userId': serializer.toJson<String>(userId),
      'action': serializer.toJson<String>(action),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String?>(entityId),
      'beforeValueJson': serializer.toJson<String?>(beforeValueJson),
      'afterValueJson': serializer.toJson<String?>(afterValueJson),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  AuditLog copyWith({
    String? id,
    String? storeId,
    String? userId,
    String? action,
    String? entityType,
    Value<String?> entityId = const Value.absent(),
    Value<String?> beforeValueJson = const Value.absent(),
    Value<String?> afterValueJson = const Value.absent(),
    DateTime? timestamp,
  }) => AuditLog(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    userId: userId ?? this.userId,
    action: action ?? this.action,
    entityType: entityType ?? this.entityType,
    entityId: entityId.present ? entityId.value : this.entityId,
    beforeValueJson: beforeValueJson.present
        ? beforeValueJson.value
        : this.beforeValueJson,
    afterValueJson: afterValueJson.present
        ? afterValueJson.value
        : this.afterValueJson,
    timestamp: timestamp ?? this.timestamp,
  );
  AuditLog copyWithCompanion(AuditLogsCompanion data) {
    return AuditLog(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      userId: data.userId.present ? data.userId.value : this.userId,
      action: data.action.present ? data.action.value : this.action,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      beforeValueJson: data.beforeValueJson.present
          ? data.beforeValueJson.value
          : this.beforeValueJson,
      afterValueJson: data.afterValueJson.present
          ? data.afterValueJson.value
          : this.afterValueJson,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('userId: $userId, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('beforeValueJson: $beforeValueJson, ')
          ..write('afterValueJson: $afterValueJson, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    userId,
    action,
    entityType,
    entityId,
    beforeValueJson,
    afterValueJson,
    timestamp,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.userId == this.userId &&
          other.action == this.action &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.beforeValueJson == this.beforeValueJson &&
          other.afterValueJson == this.afterValueJson &&
          other.timestamp == this.timestamp);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLog> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> userId;
  final Value<String> action;
  final Value<String> entityType;
  final Value<String?> entityId;
  final Value<String?> beforeValueJson;
  final Value<String?> afterValueJson;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const AuditLogsCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.userId = const Value.absent(),
    this.action = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.beforeValueJson = const Value.absent(),
    this.afterValueJson = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    required String id,
    required String storeId,
    required String userId,
    required String action,
    required String entityType,
    this.entityId = const Value.absent(),
    this.beforeValueJson = const Value.absent(),
    this.afterValueJson = const Value.absent(),
    required DateTime timestamp,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       userId = Value(userId),
       action = Value(action),
       entityType = Value(entityType),
       timestamp = Value(timestamp);
  static Insertable<AuditLog> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? userId,
    Expression<String>? action,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? beforeValueJson,
    Expression<String>? afterValueJson,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (userId != null) 'user_id': userId,
      if (action != null) 'action': action,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (beforeValueJson != null) 'before_value_json': beforeValueJson,
      if (afterValueJson != null) 'after_value_json': afterValueJson,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? userId,
    Value<String>? action,
    Value<String>? entityType,
    Value<String?>? entityId,
    Value<String?>? beforeValueJson,
    Value<String?>? afterValueJson,
    Value<DateTime>? timestamp,
    Value<int>? rowid,
  }) {
    return AuditLogsCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      userId: userId ?? this.userId,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      beforeValueJson: beforeValueJson ?? this.beforeValueJson,
      afterValueJson: afterValueJson ?? this.afterValueJson,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (beforeValueJson.present) {
      map['before_value_json'] = Variable<String>(beforeValueJson.value);
    }
    if (afterValueJson.present) {
      map['after_value_json'] = Variable<String>(afterValueJson.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('userId: $userId, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('beforeValueJson: $beforeValueJson, ')
          ..write('afterValueJson: $afterValueJson, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $StoresTable stores = $StoresTable(this);
  late final $BranchesTable branches = $BranchesTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $ActivationCodesTable activationCodes = $ActivationCodesTable(
    this,
  );
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TaxRatesTable taxRates = $TaxRatesTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $StockItemsTable stockItems = $StockItemsTable(this);
  late final $StockMovementsTable stockMovements = $StockMovementsTable(this);
  late final $StockTransfersTable stockTransfers = $StockTransfersTable(this);
  late final $StockTransferLinesTable stockTransferLines =
      $StockTransferLinesTable(this);
  late final $PurchaseOrdersTable purchaseOrders = $PurchaseOrdersTable(this);
  late final $PurchaseOrderLinesTable purchaseOrderLines =
      $PurchaseOrderLinesTable(this);
  late final $DiscountsTable discounts = $DiscountsTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $DebtLedgerEntriesTable debtLedgerEntries =
      $DebtLedgerEntriesTable(this);
  late final $DebtPaymentsTable debtPayments = $DebtPaymentsTable(this);
  late final $SuppliersTable suppliers = $SuppliersTable(this);
  late final $SupplierTransactionsTable supplierTransactions =
      $SupplierTransactionsTable(this);
  late final $ChartOfAccountsTable chartOfAccounts = $ChartOfAccountsTable(
    this,
  );
  late final $JournalEntriesTable journalEntries = $JournalEntriesTable(this);
  late final $JournalLinesTable journalLines = $JournalLinesTable(this);
  late final $SalesTable sales = $SalesTable(this);
  late final $SaleLinesTable saleLines = $SaleLinesTable(this);
  late final $SaleReturnsTable saleReturns = $SaleReturnsTable(this);
  late final $SaleReturnLinesTable saleReturnLines = $SaleReturnLinesTable(
    this,
  );
  late final $ShiftsTable shifts = $ShiftsTable(this);
  late final $AppSettingsTableTable appSettingsTable = $AppSettingsTableTable(
    this,
  );
  late final $BackupLogsTable backupLogs = $BackupLogsTable(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    stores,
    branches,
    users,
    activationCodes,
    categories,
    taxRates,
    products,
    stockItems,
    stockMovements,
    stockTransfers,
    stockTransferLines,
    purchaseOrders,
    purchaseOrderLines,
    discounts,
    customers,
    debtLedgerEntries,
    debtPayments,
    suppliers,
    supplierTransactions,
    chartOfAccounts,
    journalEntries,
    journalLines,
    sales,
    saleLines,
    saleReturns,
    saleReturnLines,
    shifts,
    appSettingsTable,
    backupLogs,
    auditLogs,
  ];
}

typedef $$StoresTableCreateCompanionBuilder =
    StoresCompanion Function({
      required String id,
      required String storeLoginId,
      required String passwordHash,
      required String displayName,
      Value<String?> activationCodeId,
      required DateTime createdAt,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$StoresTableUpdateCompanionBuilder =
    StoresCompanion Function({
      Value<String> id,
      Value<String> storeLoginId,
      Value<String> passwordHash,
      Value<String> displayName,
      Value<String?> activationCodeId,
      Value<DateTime> createdAt,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$StoresTableFilterComposer
    extends Composer<_$AppDatabase, $StoresTable> {
  $$StoresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeLoginId => $composableBuilder(
    column: $table.storeLoginId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activationCodeId => $composableBuilder(
    column: $table.activationCodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StoresTableOrderingComposer
    extends Composer<_$AppDatabase, $StoresTable> {
  $$StoresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeLoginId => $composableBuilder(
    column: $table.storeLoginId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activationCodeId => $composableBuilder(
    column: $table.activationCodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StoresTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoresTable> {
  $$StoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeLoginId => $composableBuilder(
    column: $table.storeLoginId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activationCodeId => $composableBuilder(
    column: $table.activationCodeId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$StoresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StoresTable,
          Store,
          $$StoresTableFilterComposer,
          $$StoresTableOrderingComposer,
          $$StoresTableAnnotationComposer,
          $$StoresTableCreateCompanionBuilder,
          $$StoresTableUpdateCompanionBuilder,
          (Store, BaseReferences<_$AppDatabase, $StoresTable, Store>),
          Store,
          PrefetchHooks Function()
        > {
  $$StoresTableTableManager(_$AppDatabase db, $StoresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeLoginId = const Value.absent(),
                Value<String> passwordHash = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> activationCodeId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoresCompanion(
                id: id,
                storeLoginId: storeLoginId,
                passwordHash: passwordHash,
                displayName: displayName,
                activationCodeId: activationCodeId,
                createdAt: createdAt,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeLoginId,
                required String passwordHash,
                required String displayName,
                Value<String?> activationCodeId = const Value.absent(),
                required DateTime createdAt,
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoresCompanion.insert(
                id: id,
                storeLoginId: storeLoginId,
                passwordHash: passwordHash,
                displayName: displayName,
                activationCodeId: activationCodeId,
                createdAt: createdAt,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StoresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StoresTable,
      Store,
      $$StoresTableFilterComposer,
      $$StoresTableOrderingComposer,
      $$StoresTableAnnotationComposer,
      $$StoresTableCreateCompanionBuilder,
      $$StoresTableUpdateCompanionBuilder,
      (Store, BaseReferences<_$AppDatabase, $StoresTable, Store>),
      Store,
      PrefetchHooks Function()
    >;
typedef $$BranchesTableCreateCompanionBuilder =
    BranchesCompanion Function({
      required String id,
      required String storeId,
      required String name,
      Value<String> address,
      Value<String> phone,
      Value<bool> isMainBranch,
      Value<bool> isActive,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BranchesTableUpdateCompanionBuilder =
    BranchesCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> name,
      Value<String> address,
      Value<String> phone,
      Value<bool> isMainBranch,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$BranchesTableFilterComposer
    extends Composer<_$AppDatabase, $BranchesTable> {
  $$BranchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMainBranch => $composableBuilder(
    column: $table.isMainBranch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BranchesTableOrderingComposer
    extends Composer<_$AppDatabase, $BranchesTable> {
  $$BranchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMainBranch => $composableBuilder(
    column: $table.isMainBranch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BranchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BranchesTable> {
  $$BranchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<bool> get isMainBranch => $composableBuilder(
    column: $table.isMainBranch,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BranchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BranchesTable,
          Branch,
          $$BranchesTableFilterComposer,
          $$BranchesTableOrderingComposer,
          $$BranchesTableAnnotationComposer,
          $$BranchesTableCreateCompanionBuilder,
          $$BranchesTableUpdateCompanionBuilder,
          (Branch, BaseReferences<_$AppDatabase, $BranchesTable, Branch>),
          Branch,
          PrefetchHooks Function()
        > {
  $$BranchesTableTableManager(_$AppDatabase db, $BranchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BranchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BranchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BranchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<bool> isMainBranch = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BranchesCompanion(
                id: id,
                storeId: storeId,
                name: name,
                address: address,
                phone: phone,
                isMainBranch: isMainBranch,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String name,
                Value<String> address = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<bool> isMainBranch = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BranchesCompanion.insert(
                id: id,
                storeId: storeId,
                name: name,
                address: address,
                phone: phone,
                isMainBranch: isMainBranch,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BranchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BranchesTable,
      Branch,
      $$BranchesTableFilterComposer,
      $$BranchesTableOrderingComposer,
      $$BranchesTableAnnotationComposer,
      $$BranchesTableCreateCompanionBuilder,
      $$BranchesTableUpdateCompanionBuilder,
      (Branch, BaseReferences<_$AppDatabase, $BranchesTable, Branch>),
      Branch,
      PrefetchHooks Function()
    >;
typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required String storeId,
      Value<String?> branchId,
      required String name,
      required String role,
      required String pinHash,
      Value<String> phone,
      Value<String> address,
      Value<int> salaryMinorUnits,
      Value<int> allowancesMinorUnits,
      Value<String> avatarColorHex,
      Value<bool> isActive,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String?> branchId,
      Value<String> name,
      Value<String> role,
      Value<String> pinHash,
      Value<String> phone,
      Value<String> address,
      Value<int> salaryMinorUnits,
      Value<int> allowancesMinorUnits,
      Value<String> avatarColorHex,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get salaryMinorUnits => $composableBuilder(
    column: $table.salaryMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get allowancesMinorUnits => $composableBuilder(
    column: $table.allowancesMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarColorHex => $composableBuilder(
    column: $table.avatarColorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get salaryMinorUnits => $composableBuilder(
    column: $table.salaryMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get allowancesMinorUnits => $composableBuilder(
    column: $table.allowancesMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarColorHex => $composableBuilder(
    column: $table.avatarColorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<int> get salaryMinorUnits => $composableBuilder(
    column: $table.salaryMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get allowancesMinorUnits => $composableBuilder(
    column: $table.allowancesMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarColorHex => $composableBuilder(
    column: $table.avatarColorHex,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String?> branchId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> pinHash = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<int> salaryMinorUnits = const Value.absent(),
                Value<int> allowancesMinorUnits = const Value.absent(),
                Value<String> avatarColorHex = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                storeId: storeId,
                branchId: branchId,
                name: name,
                role: role,
                pinHash: pinHash,
                phone: phone,
                address: address,
                salaryMinorUnits: salaryMinorUnits,
                allowancesMinorUnits: allowancesMinorUnits,
                avatarColorHex: avatarColorHex,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                Value<String?> branchId = const Value.absent(),
                required String name,
                required String role,
                required String pinHash,
                Value<String> phone = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<int> salaryMinorUnits = const Value.absent(),
                Value<int> allowancesMinorUnits = const Value.absent(),
                Value<String> avatarColorHex = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                storeId: storeId,
                branchId: branchId,
                name: name,
                role: role,
                pinHash: pinHash,
                phone: phone,
                address: address,
                salaryMinorUnits: salaryMinorUnits,
                allowancesMinorUnits: allowancesMinorUnits,
                avatarColorHex: avatarColorHex,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$ActivationCodesTableCreateCompanionBuilder =
    ActivationCodesCompanion Function({
      required String id,
      required String code,
      required String storeNameRef,
      required String tier,
      required DateTime issuedAt,
      Value<DateTime?> expiresAt,
      Value<String> status,
      Value<String?> redeemedByStoreId,
      Value<DateTime?> redeemedAt,
      Value<int> rowid,
    });
typedef $$ActivationCodesTableUpdateCompanionBuilder =
    ActivationCodesCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<String> storeNameRef,
      Value<String> tier,
      Value<DateTime> issuedAt,
      Value<DateTime?> expiresAt,
      Value<String> status,
      Value<String?> redeemedByStoreId,
      Value<DateTime?> redeemedAt,
      Value<int> rowid,
    });

class $$ActivationCodesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivationCodesTable> {
  $$ActivationCodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeNameRef => $composableBuilder(
    column: $table.storeNameRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get issuedAt => $composableBuilder(
    column: $table.issuedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get redeemedByStoreId => $composableBuilder(
    column: $table.redeemedByStoreId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get redeemedAt => $composableBuilder(
    column: $table.redeemedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivationCodesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivationCodesTable> {
  $$ActivationCodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeNameRef => $composableBuilder(
    column: $table.storeNameRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get issuedAt => $composableBuilder(
    column: $table.issuedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get redeemedByStoreId => $composableBuilder(
    column: $table.redeemedByStoreId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get redeemedAt => $composableBuilder(
    column: $table.redeemedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivationCodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivationCodesTable> {
  $$ActivationCodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get storeNameRef => $composableBuilder(
    column: $table.storeNameRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<DateTime> get issuedAt =>
      $composableBuilder(column: $table.issuedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get redeemedByStoreId => $composableBuilder(
    column: $table.redeemedByStoreId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get redeemedAt => $composableBuilder(
    column: $table.redeemedAt,
    builder: (column) => column,
  );
}

class $$ActivationCodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivationCodesTable,
          ActivationCode,
          $$ActivationCodesTableFilterComposer,
          $$ActivationCodesTableOrderingComposer,
          $$ActivationCodesTableAnnotationComposer,
          $$ActivationCodesTableCreateCompanionBuilder,
          $$ActivationCodesTableUpdateCompanionBuilder,
          (
            ActivationCode,
            BaseReferences<
              _$AppDatabase,
              $ActivationCodesTable,
              ActivationCode
            >,
          ),
          ActivationCode,
          PrefetchHooks Function()
        > {
  $$ActivationCodesTableTableManager(
    _$AppDatabase db,
    $ActivationCodesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivationCodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivationCodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivationCodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> storeNameRef = const Value.absent(),
                Value<String> tier = const Value.absent(),
                Value<DateTime> issuedAt = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> redeemedByStoreId = const Value.absent(),
                Value<DateTime?> redeemedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivationCodesCompanion(
                id: id,
                code: code,
                storeNameRef: storeNameRef,
                tier: tier,
                issuedAt: issuedAt,
                expiresAt: expiresAt,
                status: status,
                redeemedByStoreId: redeemedByStoreId,
                redeemedAt: redeemedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required String storeNameRef,
                required String tier,
                required DateTime issuedAt,
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> redeemedByStoreId = const Value.absent(),
                Value<DateTime?> redeemedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivationCodesCompanion.insert(
                id: id,
                code: code,
                storeNameRef: storeNameRef,
                tier: tier,
                issuedAt: issuedAt,
                expiresAt: expiresAt,
                status: status,
                redeemedByStoreId: redeemedByStoreId,
                redeemedAt: redeemedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivationCodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivationCodesTable,
      ActivationCode,
      $$ActivationCodesTableFilterComposer,
      $$ActivationCodesTableOrderingComposer,
      $$ActivationCodesTableAnnotationComposer,
      $$ActivationCodesTableCreateCompanionBuilder,
      $$ActivationCodesTableUpdateCompanionBuilder,
      (
        ActivationCode,
        BaseReferences<_$AppDatabase, $ActivationCodesTable, ActivationCode>,
      ),
      ActivationCode,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String storeId,
      required String name,
      Value<String?> parentCategoryId,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> name,
      Value<String?> parentCategoryId,
      Value<int> rowid,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentCategoryId => $composableBuilder(
    column: $table.parentCategoryId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentCategoryId => $composableBuilder(
    column: $table.parentCategoryId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get parentCategoryId => $composableBuilder(
    column: $table.parentCategoryId,
    builder: (column) => column,
  );
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
          Category,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> parentCategoryId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                storeId: storeId,
                name: name,
                parentCategoryId: parentCategoryId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String name,
                Value<String?> parentCategoryId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                storeId: storeId,
                name: name,
                parentCategoryId: parentCategoryId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
      Category,
      PrefetchHooks Function()
    >;
typedef $$TaxRatesTableCreateCompanionBuilder =
    TaxRatesCompanion Function({
      required String id,
      required String storeId,
      required String name,
      required double ratePercent,
      Value<bool> isDefault,
      Value<int> rowid,
    });
typedef $$TaxRatesTableUpdateCompanionBuilder =
    TaxRatesCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> name,
      Value<double> ratePercent,
      Value<bool> isDefault,
      Value<int> rowid,
    });

class $$TaxRatesTableFilterComposer
    extends Composer<_$AppDatabase, $TaxRatesTable> {
  $$TaxRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ratePercent => $composableBuilder(
    column: $table.ratePercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaxRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $TaxRatesTable> {
  $$TaxRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ratePercent => $composableBuilder(
    column: $table.ratePercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaxRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaxRatesTable> {
  $$TaxRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get ratePercent => $composableBuilder(
    column: $table.ratePercent,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);
}

class $$TaxRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaxRatesTable,
          TaxRate,
          $$TaxRatesTableFilterComposer,
          $$TaxRatesTableOrderingComposer,
          $$TaxRatesTableAnnotationComposer,
          $$TaxRatesTableCreateCompanionBuilder,
          $$TaxRatesTableUpdateCompanionBuilder,
          (TaxRate, BaseReferences<_$AppDatabase, $TaxRatesTable, TaxRate>),
          TaxRate,
          PrefetchHooks Function()
        > {
  $$TaxRatesTableTableManager(_$AppDatabase db, $TaxRatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaxRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaxRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaxRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> ratePercent = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaxRatesCompanion(
                id: id,
                storeId: storeId,
                name: name,
                ratePercent: ratePercent,
                isDefault: isDefault,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String name,
                required double ratePercent,
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaxRatesCompanion.insert(
                id: id,
                storeId: storeId,
                name: name,
                ratePercent: ratePercent,
                isDefault: isDefault,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaxRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaxRatesTable,
      TaxRate,
      $$TaxRatesTableFilterComposer,
      $$TaxRatesTableOrderingComposer,
      $$TaxRatesTableAnnotationComposer,
      $$TaxRatesTableCreateCompanionBuilder,
      $$TaxRatesTableUpdateCompanionBuilder,
      (TaxRate, BaseReferences<_$AppDatabase, $TaxRatesTable, TaxRate>),
      TaxRate,
      PrefetchHooks Function()
    >;
typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      required String id,
      required String storeId,
      Value<String?> categoryId,
      required String sku,
      Value<String?> barcode,
      required String name,
      Value<String> unit,
      Value<int> costPriceMinorUnits,
      Value<int> sellPriceMinorUnits,
      Value<String?> taxRateId,
      Value<int> reorderLevel,
      Value<String?> imagePath,
      Value<bool> isActive,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String?> categoryId,
      Value<String> sku,
      Value<String?> barcode,
      Value<String> name,
      Value<String> unit,
      Value<int> costPriceMinorUnits,
      Value<int> sellPriceMinorUnits,
      Value<String?> taxRateId,
      Value<int> reorderLevel,
      Value<String?> imagePath,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get costPriceMinorUnits => $composableBuilder(
    column: $table.costPriceMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sellPriceMinorUnits => $composableBuilder(
    column: $table.sellPriceMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxRateId => $composableBuilder(
    column: $table.taxRateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get costPriceMinorUnits => $composableBuilder(
    column: $table.costPriceMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sellPriceMinorUnits => $composableBuilder(
    column: $table.sellPriceMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxRateId => $composableBuilder(
    column: $table.taxRateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get costPriceMinorUnits => $composableBuilder(
    column: $table.costPriceMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sellPriceMinorUnits => $composableBuilder(
    column: $table.sellPriceMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get taxRateId =>
      $composableBuilder(column: $table.taxRateId, builder: (column) => column);

  GeneratedColumn<int> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          Product,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
          Product,
          PrefetchHooks Function()
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String> sku = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<int> costPriceMinorUnits = const Value.absent(),
                Value<int> sellPriceMinorUnits = const Value.absent(),
                Value<String?> taxRateId = const Value.absent(),
                Value<int> reorderLevel = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                storeId: storeId,
                categoryId: categoryId,
                sku: sku,
                barcode: barcode,
                name: name,
                unit: unit,
                costPriceMinorUnits: costPriceMinorUnits,
                sellPriceMinorUnits: sellPriceMinorUnits,
                taxRateId: taxRateId,
                reorderLevel: reorderLevel,
                imagePath: imagePath,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                Value<String?> categoryId = const Value.absent(),
                required String sku,
                Value<String?> barcode = const Value.absent(),
                required String name,
                Value<String> unit = const Value.absent(),
                Value<int> costPriceMinorUnits = const Value.absent(),
                Value<int> sellPriceMinorUnits = const Value.absent(),
                Value<String?> taxRateId = const Value.absent(),
                Value<int> reorderLevel = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                storeId: storeId,
                categoryId: categoryId,
                sku: sku,
                barcode: barcode,
                name: name,
                unit: unit,
                costPriceMinorUnits: costPriceMinorUnits,
                sellPriceMinorUnits: sellPriceMinorUnits,
                taxRateId: taxRateId,
                reorderLevel: reorderLevel,
                imagePath: imagePath,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      Product,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
      Product,
      PrefetchHooks Function()
    >;
typedef $$StockItemsTableCreateCompanionBuilder =
    StockItemsCompanion Function({
      required String id,
      required String storeId,
      required String productId,
      required String branchId,
      Value<int> quantityOnHand,
      Value<int> reservedQuantity,
      Value<DateTime?> lastCountedAt,
      Value<int> rowid,
    });
typedef $$StockItemsTableUpdateCompanionBuilder =
    StockItemsCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> productId,
      Value<String> branchId,
      Value<int> quantityOnHand,
      Value<int> reservedQuantity,
      Value<DateTime?> lastCountedAt,
      Value<int> rowid,
    });

class $$StockItemsTableFilterComposer
    extends Composer<_$AppDatabase, $StockItemsTable> {
  $$StockItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityOnHand => $composableBuilder(
    column: $table.quantityOnHand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reservedQuantity => $composableBuilder(
    column: $table.reservedQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCountedAt => $composableBuilder(
    column: $table.lastCountedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StockItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockItemsTable> {
  $$StockItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityOnHand => $composableBuilder(
    column: $table.quantityOnHand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reservedQuantity => $composableBuilder(
    column: $table.reservedQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCountedAt => $composableBuilder(
    column: $table.lastCountedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StockItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockItemsTable> {
  $$StockItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<int> get quantityOnHand => $composableBuilder(
    column: $table.quantityOnHand,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reservedQuantity => $composableBuilder(
    column: $table.reservedQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastCountedAt => $composableBuilder(
    column: $table.lastCountedAt,
    builder: (column) => column,
  );
}

class $$StockItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockItemsTable,
          StockItem,
          $$StockItemsTableFilterComposer,
          $$StockItemsTableOrderingComposer,
          $$StockItemsTableAnnotationComposer,
          $$StockItemsTableCreateCompanionBuilder,
          $$StockItemsTableUpdateCompanionBuilder,
          (
            StockItem,
            BaseReferences<_$AppDatabase, $StockItemsTable, StockItem>,
          ),
          StockItem,
          PrefetchHooks Function()
        > {
  $$StockItemsTableTableManager(_$AppDatabase db, $StockItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> branchId = const Value.absent(),
                Value<int> quantityOnHand = const Value.absent(),
                Value<int> reservedQuantity = const Value.absent(),
                Value<DateTime?> lastCountedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockItemsCompanion(
                id: id,
                storeId: storeId,
                productId: productId,
                branchId: branchId,
                quantityOnHand: quantityOnHand,
                reservedQuantity: reservedQuantity,
                lastCountedAt: lastCountedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String productId,
                required String branchId,
                Value<int> quantityOnHand = const Value.absent(),
                Value<int> reservedQuantity = const Value.absent(),
                Value<DateTime?> lastCountedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockItemsCompanion.insert(
                id: id,
                storeId: storeId,
                productId: productId,
                branchId: branchId,
                quantityOnHand: quantityOnHand,
                reservedQuantity: reservedQuantity,
                lastCountedAt: lastCountedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StockItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockItemsTable,
      StockItem,
      $$StockItemsTableFilterComposer,
      $$StockItemsTableOrderingComposer,
      $$StockItemsTableAnnotationComposer,
      $$StockItemsTableCreateCompanionBuilder,
      $$StockItemsTableUpdateCompanionBuilder,
      (StockItem, BaseReferences<_$AppDatabase, $StockItemsTable, StockItem>),
      StockItem,
      PrefetchHooks Function()
    >;
typedef $$StockMovementsTableCreateCompanionBuilder =
    StockMovementsCompanion Function({
      required String id,
      required String storeId,
      required String productId,
      required String branchId,
      required String type,
      required int quantity,
      Value<int> unitCostMinorUnits,
      Value<String?> referenceType,
      Value<String?> referenceId,
      required String createdByUserId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$StockMovementsTableUpdateCompanionBuilder =
    StockMovementsCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> productId,
      Value<String> branchId,
      Value<String> type,
      Value<int> quantity,
      Value<int> unitCostMinorUnits,
      Value<String?> referenceType,
      Value<String?> referenceId,
      Value<String> createdByUserId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$StockMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitCostMinorUnits => $composableBuilder(
    column: $table.unitCostMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceType => $composableBuilder(
    column: $table.referenceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StockMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitCostMinorUnits => $composableBuilder(
    column: $table.unitCostMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceType => $composableBuilder(
    column: $table.referenceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StockMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get unitCostMinorUnits => $composableBuilder(
    column: $table.unitCostMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceType => $composableBuilder(
    column: $table.referenceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$StockMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockMovementsTable,
          StockMovement,
          $$StockMovementsTableFilterComposer,
          $$StockMovementsTableOrderingComposer,
          $$StockMovementsTableAnnotationComposer,
          $$StockMovementsTableCreateCompanionBuilder,
          $$StockMovementsTableUpdateCompanionBuilder,
          (
            StockMovement,
            BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovement>,
          ),
          StockMovement,
          PrefetchHooks Function()
        > {
  $$StockMovementsTableTableManager(
    _$AppDatabase db,
    $StockMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> branchId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> unitCostMinorUnits = const Value.absent(),
                Value<String?> referenceType = const Value.absent(),
                Value<String?> referenceId = const Value.absent(),
                Value<String> createdByUserId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockMovementsCompanion(
                id: id,
                storeId: storeId,
                productId: productId,
                branchId: branchId,
                type: type,
                quantity: quantity,
                unitCostMinorUnits: unitCostMinorUnits,
                referenceType: referenceType,
                referenceId: referenceId,
                createdByUserId: createdByUserId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String productId,
                required String branchId,
                required String type,
                required int quantity,
                Value<int> unitCostMinorUnits = const Value.absent(),
                Value<String?> referenceType = const Value.absent(),
                Value<String?> referenceId = const Value.absent(),
                required String createdByUserId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => StockMovementsCompanion.insert(
                id: id,
                storeId: storeId,
                productId: productId,
                branchId: branchId,
                type: type,
                quantity: quantity,
                unitCostMinorUnits: unitCostMinorUnits,
                referenceType: referenceType,
                referenceId: referenceId,
                createdByUserId: createdByUserId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StockMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockMovementsTable,
      StockMovement,
      $$StockMovementsTableFilterComposer,
      $$StockMovementsTableOrderingComposer,
      $$StockMovementsTableAnnotationComposer,
      $$StockMovementsTableCreateCompanionBuilder,
      $$StockMovementsTableUpdateCompanionBuilder,
      (
        StockMovement,
        BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovement>,
      ),
      StockMovement,
      PrefetchHooks Function()
    >;
typedef $$StockTransfersTableCreateCompanionBuilder =
    StockTransfersCompanion Function({
      required String id,
      required String storeId,
      required String fromBranchId,
      required String toBranchId,
      Value<String> status,
      required String requestedByUserId,
      Value<String?> receivedByUserId,
      required DateTime createdAt,
      Value<DateTime?> receivedAt,
      Value<int> rowid,
    });
typedef $$StockTransfersTableUpdateCompanionBuilder =
    StockTransfersCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> fromBranchId,
      Value<String> toBranchId,
      Value<String> status,
      Value<String> requestedByUserId,
      Value<String?> receivedByUserId,
      Value<DateTime> createdAt,
      Value<DateTime?> receivedAt,
      Value<int> rowid,
    });

class $$StockTransfersTableFilterComposer
    extends Composer<_$AppDatabase, $StockTransfersTable> {
  $$StockTransfersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromBranchId => $composableBuilder(
    column: $table.fromBranchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toBranchId => $composableBuilder(
    column: $table.toBranchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestedByUserId => $composableBuilder(
    column: $table.requestedByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receivedByUserId => $composableBuilder(
    column: $table.receivedByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StockTransfersTableOrderingComposer
    extends Composer<_$AppDatabase, $StockTransfersTable> {
  $$StockTransfersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromBranchId => $composableBuilder(
    column: $table.fromBranchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toBranchId => $composableBuilder(
    column: $table.toBranchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestedByUserId => $composableBuilder(
    column: $table.requestedByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receivedByUserId => $composableBuilder(
    column: $table.receivedByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StockTransfersTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockTransfersTable> {
  $$StockTransfersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get fromBranchId => $composableBuilder(
    column: $table.fromBranchId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toBranchId => $composableBuilder(
    column: $table.toBranchId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get requestedByUserId => $composableBuilder(
    column: $table.requestedByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receivedByUserId => $composableBuilder(
    column: $table.receivedByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );
}

class $$StockTransfersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockTransfersTable,
          StockTransfer,
          $$StockTransfersTableFilterComposer,
          $$StockTransfersTableOrderingComposer,
          $$StockTransfersTableAnnotationComposer,
          $$StockTransfersTableCreateCompanionBuilder,
          $$StockTransfersTableUpdateCompanionBuilder,
          (
            StockTransfer,
            BaseReferences<_$AppDatabase, $StockTransfersTable, StockTransfer>,
          ),
          StockTransfer,
          PrefetchHooks Function()
        > {
  $$StockTransfersTableTableManager(
    _$AppDatabase db,
    $StockTransfersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockTransfersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockTransfersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockTransfersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> fromBranchId = const Value.absent(),
                Value<String> toBranchId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> requestedByUserId = const Value.absent(),
                Value<String?> receivedByUserId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> receivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockTransfersCompanion(
                id: id,
                storeId: storeId,
                fromBranchId: fromBranchId,
                toBranchId: toBranchId,
                status: status,
                requestedByUserId: requestedByUserId,
                receivedByUserId: receivedByUserId,
                createdAt: createdAt,
                receivedAt: receivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String fromBranchId,
                required String toBranchId,
                Value<String> status = const Value.absent(),
                required String requestedByUserId,
                Value<String?> receivedByUserId = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> receivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockTransfersCompanion.insert(
                id: id,
                storeId: storeId,
                fromBranchId: fromBranchId,
                toBranchId: toBranchId,
                status: status,
                requestedByUserId: requestedByUserId,
                receivedByUserId: receivedByUserId,
                createdAt: createdAt,
                receivedAt: receivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StockTransfersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockTransfersTable,
      StockTransfer,
      $$StockTransfersTableFilterComposer,
      $$StockTransfersTableOrderingComposer,
      $$StockTransfersTableAnnotationComposer,
      $$StockTransfersTableCreateCompanionBuilder,
      $$StockTransfersTableUpdateCompanionBuilder,
      (
        StockTransfer,
        BaseReferences<_$AppDatabase, $StockTransfersTable, StockTransfer>,
      ),
      StockTransfer,
      PrefetchHooks Function()
    >;
typedef $$StockTransferLinesTableCreateCompanionBuilder =
    StockTransferLinesCompanion Function({
      required String id,
      required String stockTransferId,
      required String productId,
      required int quantity,
      Value<int> rowid,
    });
typedef $$StockTransferLinesTableUpdateCompanionBuilder =
    StockTransferLinesCompanion Function({
      Value<String> id,
      Value<String> stockTransferId,
      Value<String> productId,
      Value<int> quantity,
      Value<int> rowid,
    });

class $$StockTransferLinesTableFilterComposer
    extends Composer<_$AppDatabase, $StockTransferLinesTable> {
  $$StockTransferLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stockTransferId => $composableBuilder(
    column: $table.stockTransferId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StockTransferLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $StockTransferLinesTable> {
  $$StockTransferLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stockTransferId => $composableBuilder(
    column: $table.stockTransferId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StockTransferLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockTransferLinesTable> {
  $$StockTransferLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get stockTransferId => $composableBuilder(
    column: $table.stockTransferId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);
}

class $$StockTransferLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockTransferLinesTable,
          StockTransferLine,
          $$StockTransferLinesTableFilterComposer,
          $$StockTransferLinesTableOrderingComposer,
          $$StockTransferLinesTableAnnotationComposer,
          $$StockTransferLinesTableCreateCompanionBuilder,
          $$StockTransferLinesTableUpdateCompanionBuilder,
          (
            StockTransferLine,
            BaseReferences<
              _$AppDatabase,
              $StockTransferLinesTable,
              StockTransferLine
            >,
          ),
          StockTransferLine,
          PrefetchHooks Function()
        > {
  $$StockTransferLinesTableTableManager(
    _$AppDatabase db,
    $StockTransferLinesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockTransferLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockTransferLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockTransferLinesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> stockTransferId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockTransferLinesCompanion(
                id: id,
                stockTransferId: stockTransferId,
                productId: productId,
                quantity: quantity,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String stockTransferId,
                required String productId,
                required int quantity,
                Value<int> rowid = const Value.absent(),
              }) => StockTransferLinesCompanion.insert(
                id: id,
                stockTransferId: stockTransferId,
                productId: productId,
                quantity: quantity,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StockTransferLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockTransferLinesTable,
      StockTransferLine,
      $$StockTransferLinesTableFilterComposer,
      $$StockTransferLinesTableOrderingComposer,
      $$StockTransferLinesTableAnnotationComposer,
      $$StockTransferLinesTableCreateCompanionBuilder,
      $$StockTransferLinesTableUpdateCompanionBuilder,
      (
        StockTransferLine,
        BaseReferences<
          _$AppDatabase,
          $StockTransferLinesTable,
          StockTransferLine
        >,
      ),
      StockTransferLine,
      PrefetchHooks Function()
    >;
typedef $$PurchaseOrdersTableCreateCompanionBuilder =
    PurchaseOrdersCompanion Function({
      required String id,
      required String storeId,
      required String branchId,
      required String supplierId,
      Value<String> status,
      required DateTime orderDate,
      Value<DateTime?> expectedDate,
      Value<int> totalCostMinorUnits,
      Value<bool> paidImmediately,
      Value<int> rowid,
    });
typedef $$PurchaseOrdersTableUpdateCompanionBuilder =
    PurchaseOrdersCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> branchId,
      Value<String> supplierId,
      Value<String> status,
      Value<DateTime> orderDate,
      Value<DateTime?> expectedDate,
      Value<int> totalCostMinorUnits,
      Value<bool> paidImmediately,
      Value<int> rowid,
    });

class $$PurchaseOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $PurchaseOrdersTable> {
  $$PurchaseOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get orderDate => $composableBuilder(
    column: $table.orderDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expectedDate => $composableBuilder(
    column: $table.expectedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCostMinorUnits => $composableBuilder(
    column: $table.totalCostMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get paidImmediately => $composableBuilder(
    column: $table.paidImmediately,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PurchaseOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchaseOrdersTable> {
  $$PurchaseOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get orderDate => $composableBuilder(
    column: $table.orderDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expectedDate => $composableBuilder(
    column: $table.expectedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCostMinorUnits => $composableBuilder(
    column: $table.totalCostMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get paidImmediately => $composableBuilder(
    column: $table.paidImmediately,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PurchaseOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseOrdersTable> {
  $$PurchaseOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get orderDate =>
      $composableBuilder(column: $table.orderDate, builder: (column) => column);

  GeneratedColumn<DateTime> get expectedDate => $composableBuilder(
    column: $table.expectedDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCostMinorUnits => $composableBuilder(
    column: $table.totalCostMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get paidImmediately => $composableBuilder(
    column: $table.paidImmediately,
    builder: (column) => column,
  );
}

class $$PurchaseOrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchaseOrdersTable,
          PurchaseOrder,
          $$PurchaseOrdersTableFilterComposer,
          $$PurchaseOrdersTableOrderingComposer,
          $$PurchaseOrdersTableAnnotationComposer,
          $$PurchaseOrdersTableCreateCompanionBuilder,
          $$PurchaseOrdersTableUpdateCompanionBuilder,
          (
            PurchaseOrder,
            BaseReferences<_$AppDatabase, $PurchaseOrdersTable, PurchaseOrder>,
          ),
          PurchaseOrder,
          PrefetchHooks Function()
        > {
  $$PurchaseOrdersTableTableManager(
    _$AppDatabase db,
    $PurchaseOrdersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> branchId = const Value.absent(),
                Value<String> supplierId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> orderDate = const Value.absent(),
                Value<DateTime?> expectedDate = const Value.absent(),
                Value<int> totalCostMinorUnits = const Value.absent(),
                Value<bool> paidImmediately = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseOrdersCompanion(
                id: id,
                storeId: storeId,
                branchId: branchId,
                supplierId: supplierId,
                status: status,
                orderDate: orderDate,
                expectedDate: expectedDate,
                totalCostMinorUnits: totalCostMinorUnits,
                paidImmediately: paidImmediately,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String branchId,
                required String supplierId,
                Value<String> status = const Value.absent(),
                required DateTime orderDate,
                Value<DateTime?> expectedDate = const Value.absent(),
                Value<int> totalCostMinorUnits = const Value.absent(),
                Value<bool> paidImmediately = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseOrdersCompanion.insert(
                id: id,
                storeId: storeId,
                branchId: branchId,
                supplierId: supplierId,
                status: status,
                orderDate: orderDate,
                expectedDate: expectedDate,
                totalCostMinorUnits: totalCostMinorUnits,
                paidImmediately: paidImmediately,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PurchaseOrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchaseOrdersTable,
      PurchaseOrder,
      $$PurchaseOrdersTableFilterComposer,
      $$PurchaseOrdersTableOrderingComposer,
      $$PurchaseOrdersTableAnnotationComposer,
      $$PurchaseOrdersTableCreateCompanionBuilder,
      $$PurchaseOrdersTableUpdateCompanionBuilder,
      (
        PurchaseOrder,
        BaseReferences<_$AppDatabase, $PurchaseOrdersTable, PurchaseOrder>,
      ),
      PurchaseOrder,
      PrefetchHooks Function()
    >;
typedef $$PurchaseOrderLinesTableCreateCompanionBuilder =
    PurchaseOrderLinesCompanion Function({
      required String id,
      required String purchaseOrderId,
      required String productId,
      required int quantityOrdered,
      Value<int> quantityReceived,
      required int unitCostMinorUnits,
      Value<int> rowid,
    });
typedef $$PurchaseOrderLinesTableUpdateCompanionBuilder =
    PurchaseOrderLinesCompanion Function({
      Value<String> id,
      Value<String> purchaseOrderId,
      Value<String> productId,
      Value<int> quantityOrdered,
      Value<int> quantityReceived,
      Value<int> unitCostMinorUnits,
      Value<int> rowid,
    });

class $$PurchaseOrderLinesTableFilterComposer
    extends Composer<_$AppDatabase, $PurchaseOrderLinesTable> {
  $$PurchaseOrderLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purchaseOrderId => $composableBuilder(
    column: $table.purchaseOrderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityOrdered => $composableBuilder(
    column: $table.quantityOrdered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityReceived => $composableBuilder(
    column: $table.quantityReceived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitCostMinorUnits => $composableBuilder(
    column: $table.unitCostMinorUnits,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PurchaseOrderLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchaseOrderLinesTable> {
  $$PurchaseOrderLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purchaseOrderId => $composableBuilder(
    column: $table.purchaseOrderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityOrdered => $composableBuilder(
    column: $table.quantityOrdered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityReceived => $composableBuilder(
    column: $table.quantityReceived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitCostMinorUnits => $composableBuilder(
    column: $table.unitCostMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PurchaseOrderLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseOrderLinesTable> {
  $$PurchaseOrderLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get purchaseOrderId => $composableBuilder(
    column: $table.purchaseOrderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get quantityOrdered => $composableBuilder(
    column: $table.quantityOrdered,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantityReceived => $composableBuilder(
    column: $table.quantityReceived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unitCostMinorUnits => $composableBuilder(
    column: $table.unitCostMinorUnits,
    builder: (column) => column,
  );
}

class $$PurchaseOrderLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchaseOrderLinesTable,
          PurchaseOrderLine,
          $$PurchaseOrderLinesTableFilterComposer,
          $$PurchaseOrderLinesTableOrderingComposer,
          $$PurchaseOrderLinesTableAnnotationComposer,
          $$PurchaseOrderLinesTableCreateCompanionBuilder,
          $$PurchaseOrderLinesTableUpdateCompanionBuilder,
          (
            PurchaseOrderLine,
            BaseReferences<
              _$AppDatabase,
              $PurchaseOrderLinesTable,
              PurchaseOrderLine
            >,
          ),
          PurchaseOrderLine,
          PrefetchHooks Function()
        > {
  $$PurchaseOrderLinesTableTableManager(
    _$AppDatabase db,
    $PurchaseOrderLinesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseOrderLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseOrderLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseOrderLinesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> purchaseOrderId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<int> quantityOrdered = const Value.absent(),
                Value<int> quantityReceived = const Value.absent(),
                Value<int> unitCostMinorUnits = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseOrderLinesCompanion(
                id: id,
                purchaseOrderId: purchaseOrderId,
                productId: productId,
                quantityOrdered: quantityOrdered,
                quantityReceived: quantityReceived,
                unitCostMinorUnits: unitCostMinorUnits,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String purchaseOrderId,
                required String productId,
                required int quantityOrdered,
                Value<int> quantityReceived = const Value.absent(),
                required int unitCostMinorUnits,
                Value<int> rowid = const Value.absent(),
              }) => PurchaseOrderLinesCompanion.insert(
                id: id,
                purchaseOrderId: purchaseOrderId,
                productId: productId,
                quantityOrdered: quantityOrdered,
                quantityReceived: quantityReceived,
                unitCostMinorUnits: unitCostMinorUnits,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PurchaseOrderLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchaseOrderLinesTable,
      PurchaseOrderLine,
      $$PurchaseOrderLinesTableFilterComposer,
      $$PurchaseOrderLinesTableOrderingComposer,
      $$PurchaseOrderLinesTableAnnotationComposer,
      $$PurchaseOrderLinesTableCreateCompanionBuilder,
      $$PurchaseOrderLinesTableUpdateCompanionBuilder,
      (
        PurchaseOrderLine,
        BaseReferences<
          _$AppDatabase,
          $PurchaseOrderLinesTable,
          PurchaseOrderLine
        >,
      ),
      PurchaseOrderLine,
      PrefetchHooks Function()
    >;
typedef $$DiscountsTableCreateCompanionBuilder =
    DiscountsCompanion Function({
      required String id,
      required String storeId,
      required String name,
      required String type,
      required int value,
      required String appliedScope,
      Value<String?> scopeTargetId,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$DiscountsTableUpdateCompanionBuilder =
    DiscountsCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> name,
      Value<String> type,
      Value<int> value,
      Value<String> appliedScope,
      Value<String?> scopeTargetId,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$DiscountsTableFilterComposer
    extends Composer<_$AppDatabase, $DiscountsTable> {
  $$DiscountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appliedScope => $composableBuilder(
    column: $table.appliedScope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeTargetId => $composableBuilder(
    column: $table.scopeTargetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DiscountsTableOrderingComposer
    extends Composer<_$AppDatabase, $DiscountsTable> {
  $$DiscountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appliedScope => $composableBuilder(
    column: $table.appliedScope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeTargetId => $composableBuilder(
    column: $table.scopeTargetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DiscountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiscountsTable> {
  $$DiscountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get appliedScope => $composableBuilder(
    column: $table.appliedScope,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scopeTargetId => $composableBuilder(
    column: $table.scopeTargetId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$DiscountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DiscountsTable,
          Discount,
          $$DiscountsTableFilterComposer,
          $$DiscountsTableOrderingComposer,
          $$DiscountsTableAnnotationComposer,
          $$DiscountsTableCreateCompanionBuilder,
          $$DiscountsTableUpdateCompanionBuilder,
          (Discount, BaseReferences<_$AppDatabase, $DiscountsTable, Discount>),
          Discount,
          PrefetchHooks Function()
        > {
  $$DiscountsTableTableManager(_$AppDatabase db, $DiscountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiscountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiscountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiscountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> value = const Value.absent(),
                Value<String> appliedScope = const Value.absent(),
                Value<String?> scopeTargetId = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DiscountsCompanion(
                id: id,
                storeId: storeId,
                name: name,
                type: type,
                value: value,
                appliedScope: appliedScope,
                scopeTargetId: scopeTargetId,
                startDate: startDate,
                endDate: endDate,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String name,
                required String type,
                required int value,
                required String appliedScope,
                Value<String?> scopeTargetId = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DiscountsCompanion.insert(
                id: id,
                storeId: storeId,
                name: name,
                type: type,
                value: value,
                appliedScope: appliedScope,
                scopeTargetId: scopeTargetId,
                startDate: startDate,
                endDate: endDate,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DiscountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DiscountsTable,
      Discount,
      $$DiscountsTableFilterComposer,
      $$DiscountsTableOrderingComposer,
      $$DiscountsTableAnnotationComposer,
      $$DiscountsTableCreateCompanionBuilder,
      $$DiscountsTableUpdateCompanionBuilder,
      (Discount, BaseReferences<_$AppDatabase, $DiscountsTable, Discount>),
      Discount,
      PrefetchHooks Function()
    >;
typedef $$CustomersTableCreateCompanionBuilder =
    CustomersCompanion Function({
      required String id,
      required String storeId,
      required String name,
      Value<String?> phone,
      Value<String?> address,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CustomersTableUpdateCompanionBuilder =
    CustomersCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> name,
      Value<String?> phone,
      Value<String?> address,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          Customer,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
          Customer,
          PrefetchHooks Function()
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                storeId: storeId,
                name: name,
                phone: phone,
                address: address,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String name,
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                storeId: storeId,
                name: name,
                phone: phone,
                address: address,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      Customer,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
      Customer,
      PrefetchHooks Function()
    >;
typedef $$DebtLedgerEntriesTableCreateCompanionBuilder =
    DebtLedgerEntriesCompanion Function({
      required String id,
      required String storeId,
      required String branchId,
      required String customerId,
      Value<String?> saleId,
      Value<String?> journalEntryId,
      required int originalAmountMinorUnits,
      Value<int> amountPaidMinorUnits,
      Value<String?> receiptRef,
      Value<String> status,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$DebtLedgerEntriesTableUpdateCompanionBuilder =
    DebtLedgerEntriesCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> branchId,
      Value<String> customerId,
      Value<String?> saleId,
      Value<String?> journalEntryId,
      Value<int> originalAmountMinorUnits,
      Value<int> amountPaidMinorUnits,
      Value<String?> receiptRef,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$DebtLedgerEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DebtLedgerEntriesTable> {
  $$DebtLedgerEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalAmountMinorUnits => $composableBuilder(
    column: $table.originalAmountMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaidMinorUnits => $composableBuilder(
    column: $table.amountPaidMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptRef => $composableBuilder(
    column: $table.receiptRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DebtLedgerEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtLedgerEntriesTable> {
  $$DebtLedgerEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalAmountMinorUnits => $composableBuilder(
    column: $table.originalAmountMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaidMinorUnits => $composableBuilder(
    column: $table.amountPaidMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptRef => $composableBuilder(
    column: $table.receiptRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DebtLedgerEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtLedgerEntriesTable> {
  $$DebtLedgerEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get originalAmountMinorUnits => $composableBuilder(
    column: $table.originalAmountMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountPaidMinorUnits => $composableBuilder(
    column: $table.amountPaidMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptRef => $composableBuilder(
    column: $table.receiptRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DebtLedgerEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebtLedgerEntriesTable,
          DebtLedgerEntry,
          $$DebtLedgerEntriesTableFilterComposer,
          $$DebtLedgerEntriesTableOrderingComposer,
          $$DebtLedgerEntriesTableAnnotationComposer,
          $$DebtLedgerEntriesTableCreateCompanionBuilder,
          $$DebtLedgerEntriesTableUpdateCompanionBuilder,
          (
            DebtLedgerEntry,
            BaseReferences<
              _$AppDatabase,
              $DebtLedgerEntriesTable,
              DebtLedgerEntry
            >,
          ),
          DebtLedgerEntry,
          PrefetchHooks Function()
        > {
  $$DebtLedgerEntriesTableTableManager(
    _$AppDatabase db,
    $DebtLedgerEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebtLedgerEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebtLedgerEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebtLedgerEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> branchId = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String?> saleId = const Value.absent(),
                Value<String?> journalEntryId = const Value.absent(),
                Value<int> originalAmountMinorUnits = const Value.absent(),
                Value<int> amountPaidMinorUnits = const Value.absent(),
                Value<String?> receiptRef = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebtLedgerEntriesCompanion(
                id: id,
                storeId: storeId,
                branchId: branchId,
                customerId: customerId,
                saleId: saleId,
                journalEntryId: journalEntryId,
                originalAmountMinorUnits: originalAmountMinorUnits,
                amountPaidMinorUnits: amountPaidMinorUnits,
                receiptRef: receiptRef,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String branchId,
                required String customerId,
                Value<String?> saleId = const Value.absent(),
                Value<String?> journalEntryId = const Value.absent(),
                required int originalAmountMinorUnits,
                Value<int> amountPaidMinorUnits = const Value.absent(),
                Value<String?> receiptRef = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DebtLedgerEntriesCompanion.insert(
                id: id,
                storeId: storeId,
                branchId: branchId,
                customerId: customerId,
                saleId: saleId,
                journalEntryId: journalEntryId,
                originalAmountMinorUnits: originalAmountMinorUnits,
                amountPaidMinorUnits: amountPaidMinorUnits,
                receiptRef: receiptRef,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DebtLedgerEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebtLedgerEntriesTable,
      DebtLedgerEntry,
      $$DebtLedgerEntriesTableFilterComposer,
      $$DebtLedgerEntriesTableOrderingComposer,
      $$DebtLedgerEntriesTableAnnotationComposer,
      $$DebtLedgerEntriesTableCreateCompanionBuilder,
      $$DebtLedgerEntriesTableUpdateCompanionBuilder,
      (
        DebtLedgerEntry,
        BaseReferences<_$AppDatabase, $DebtLedgerEntriesTable, DebtLedgerEntry>,
      ),
      DebtLedgerEntry,
      PrefetchHooks Function()
    >;
typedef $$DebtPaymentsTableCreateCompanionBuilder =
    DebtPaymentsCompanion Function({
      required String id,
      required String debtLedgerEntryId,
      required int amountMinorUnits,
      required String paymentMethod,
      required String receivedByUserId,
      Value<String?> journalEntryId,
      required DateTime paidAt,
      Value<int> rowid,
    });
typedef $$DebtPaymentsTableUpdateCompanionBuilder =
    DebtPaymentsCompanion Function({
      Value<String> id,
      Value<String> debtLedgerEntryId,
      Value<int> amountMinorUnits,
      Value<String> paymentMethod,
      Value<String> receivedByUserId,
      Value<String?> journalEntryId,
      Value<DateTime> paidAt,
      Value<int> rowid,
    });

class $$DebtPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $DebtPaymentsTable> {
  $$DebtPaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get debtLedgerEntryId => $composableBuilder(
    column: $table.debtLedgerEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receivedByUserId => $composableBuilder(
    column: $table.receivedByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DebtPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtPaymentsTable> {
  $$DebtPaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get debtLedgerEntryId => $composableBuilder(
    column: $table.debtLedgerEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receivedByUserId => $composableBuilder(
    column: $table.receivedByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DebtPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtPaymentsTable> {
  $$DebtPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get debtLedgerEntryId => $composableBuilder(
    column: $table.debtLedgerEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receivedByUserId => $composableBuilder(
    column: $table.receivedByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);
}

class $$DebtPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebtPaymentsTable,
          DebtPayment,
          $$DebtPaymentsTableFilterComposer,
          $$DebtPaymentsTableOrderingComposer,
          $$DebtPaymentsTableAnnotationComposer,
          $$DebtPaymentsTableCreateCompanionBuilder,
          $$DebtPaymentsTableUpdateCompanionBuilder,
          (
            DebtPayment,
            BaseReferences<_$AppDatabase, $DebtPaymentsTable, DebtPayment>,
          ),
          DebtPayment,
          PrefetchHooks Function()
        > {
  $$DebtPaymentsTableTableManager(_$AppDatabase db, $DebtPaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebtPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebtPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebtPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> debtLedgerEntryId = const Value.absent(),
                Value<int> amountMinorUnits = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String> receivedByUserId = const Value.absent(),
                Value<String?> journalEntryId = const Value.absent(),
                Value<DateTime> paidAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebtPaymentsCompanion(
                id: id,
                debtLedgerEntryId: debtLedgerEntryId,
                amountMinorUnits: amountMinorUnits,
                paymentMethod: paymentMethod,
                receivedByUserId: receivedByUserId,
                journalEntryId: journalEntryId,
                paidAt: paidAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String debtLedgerEntryId,
                required int amountMinorUnits,
                required String paymentMethod,
                required String receivedByUserId,
                Value<String?> journalEntryId = const Value.absent(),
                required DateTime paidAt,
                Value<int> rowid = const Value.absent(),
              }) => DebtPaymentsCompanion.insert(
                id: id,
                debtLedgerEntryId: debtLedgerEntryId,
                amountMinorUnits: amountMinorUnits,
                paymentMethod: paymentMethod,
                receivedByUserId: receivedByUserId,
                journalEntryId: journalEntryId,
                paidAt: paidAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DebtPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebtPaymentsTable,
      DebtPayment,
      $$DebtPaymentsTableFilterComposer,
      $$DebtPaymentsTableOrderingComposer,
      $$DebtPaymentsTableAnnotationComposer,
      $$DebtPaymentsTableCreateCompanionBuilder,
      $$DebtPaymentsTableUpdateCompanionBuilder,
      (
        DebtPayment,
        BaseReferences<_$AppDatabase, $DebtPaymentsTable, DebtPayment>,
      ),
      DebtPayment,
      PrefetchHooks Function()
    >;
typedef $$SuppliersTableCreateCompanionBuilder =
    SuppliersCompanion Function({
      required String id,
      required String storeId,
      required String name,
      Value<String?> contactPhone,
      Value<String?> contactPerson,
      Value<String?> address,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SuppliersTableUpdateCompanionBuilder =
    SuppliersCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> name,
      Value<String?> contactPhone,
      Value<String?> contactPerson,
      Value<String?> address,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SuppliersTableFilterComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactPhone => $composableBuilder(
    column: $table.contactPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SuppliersTableOrderingComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactPhone => $composableBuilder(
    column: $table.contactPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SuppliersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get contactPhone => $composableBuilder(
    column: $table.contactPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SuppliersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuppliersTable,
          Supplier,
          $$SuppliersTableFilterComposer,
          $$SuppliersTableOrderingComposer,
          $$SuppliersTableAnnotationComposer,
          $$SuppliersTableCreateCompanionBuilder,
          $$SuppliersTableUpdateCompanionBuilder,
          (Supplier, BaseReferences<_$AppDatabase, $SuppliersTable, Supplier>),
          Supplier,
          PrefetchHooks Function()
        > {
  $$SuppliersTableTableManager(_$AppDatabase db, $SuppliersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppliersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppliersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppliersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> contactPhone = const Value.absent(),
                Value<String?> contactPerson = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuppliersCompanion(
                id: id,
                storeId: storeId,
                name: name,
                contactPhone: contactPhone,
                contactPerson: contactPerson,
                address: address,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String name,
                Value<String?> contactPhone = const Value.absent(),
                Value<String?> contactPerson = const Value.absent(),
                Value<String?> address = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SuppliersCompanion.insert(
                id: id,
                storeId: storeId,
                name: name,
                contactPhone: contactPhone,
                contactPerson: contactPerson,
                address: address,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SuppliersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuppliersTable,
      Supplier,
      $$SuppliersTableFilterComposer,
      $$SuppliersTableOrderingComposer,
      $$SuppliersTableAnnotationComposer,
      $$SuppliersTableCreateCompanionBuilder,
      $$SuppliersTableUpdateCompanionBuilder,
      (Supplier, BaseReferences<_$AppDatabase, $SuppliersTable, Supplier>),
      Supplier,
      PrefetchHooks Function()
    >;
typedef $$SupplierTransactionsTableCreateCompanionBuilder =
    SupplierTransactionsCompanion Function({
      required String id,
      required String storeId,
      required String supplierId,
      required String type,
      required int amountMinorUnits,
      Value<String?> relatedPurchaseOrderId,
      Value<DateTime?> deliveryDate,
      Value<String?> journalEntryId,
      required String createdByUserId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SupplierTransactionsTableUpdateCompanionBuilder =
    SupplierTransactionsCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> supplierId,
      Value<String> type,
      Value<int> amountMinorUnits,
      Value<String?> relatedPurchaseOrderId,
      Value<DateTime?> deliveryDate,
      Value<String?> journalEntryId,
      Value<String> createdByUserId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SupplierTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $SupplierTransactionsTable> {
  $$SupplierTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relatedPurchaseOrderId => $composableBuilder(
    column: $table.relatedPurchaseOrderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deliveryDate => $composableBuilder(
    column: $table.deliveryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SupplierTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplierTransactionsTable> {
  $$SupplierTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relatedPurchaseOrderId => $composableBuilder(
    column: $table.relatedPurchaseOrderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deliveryDate => $composableBuilder(
    column: $table.deliveryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SupplierTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplierTransactionsTable> {
  $$SupplierTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relatedPurchaseOrderId => $composableBuilder(
    column: $table.relatedPurchaseOrderId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deliveryDate => $composableBuilder(
    column: $table.deliveryDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SupplierTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupplierTransactionsTable,
          SupplierTransaction,
          $$SupplierTransactionsTableFilterComposer,
          $$SupplierTransactionsTableOrderingComposer,
          $$SupplierTransactionsTableAnnotationComposer,
          $$SupplierTransactionsTableCreateCompanionBuilder,
          $$SupplierTransactionsTableUpdateCompanionBuilder,
          (
            SupplierTransaction,
            BaseReferences<
              _$AppDatabase,
              $SupplierTransactionsTable,
              SupplierTransaction
            >,
          ),
          SupplierTransaction,
          PrefetchHooks Function()
        > {
  $$SupplierTransactionsTableTableManager(
    _$AppDatabase db,
    $SupplierTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplierTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplierTransactionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SupplierTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> supplierId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> amountMinorUnits = const Value.absent(),
                Value<String?> relatedPurchaseOrderId = const Value.absent(),
                Value<DateTime?> deliveryDate = const Value.absent(),
                Value<String?> journalEntryId = const Value.absent(),
                Value<String> createdByUserId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplierTransactionsCompanion(
                id: id,
                storeId: storeId,
                supplierId: supplierId,
                type: type,
                amountMinorUnits: amountMinorUnits,
                relatedPurchaseOrderId: relatedPurchaseOrderId,
                deliveryDate: deliveryDate,
                journalEntryId: journalEntryId,
                createdByUserId: createdByUserId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String supplierId,
                required String type,
                required int amountMinorUnits,
                Value<String?> relatedPurchaseOrderId = const Value.absent(),
                Value<DateTime?> deliveryDate = const Value.absent(),
                Value<String?> journalEntryId = const Value.absent(),
                required String createdByUserId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SupplierTransactionsCompanion.insert(
                id: id,
                storeId: storeId,
                supplierId: supplierId,
                type: type,
                amountMinorUnits: amountMinorUnits,
                relatedPurchaseOrderId: relatedPurchaseOrderId,
                deliveryDate: deliveryDate,
                journalEntryId: journalEntryId,
                createdByUserId: createdByUserId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SupplierTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupplierTransactionsTable,
      SupplierTransaction,
      $$SupplierTransactionsTableFilterComposer,
      $$SupplierTransactionsTableOrderingComposer,
      $$SupplierTransactionsTableAnnotationComposer,
      $$SupplierTransactionsTableCreateCompanionBuilder,
      $$SupplierTransactionsTableUpdateCompanionBuilder,
      (
        SupplierTransaction,
        BaseReferences<
          _$AppDatabase,
          $SupplierTransactionsTable,
          SupplierTransaction
        >,
      ),
      SupplierTransaction,
      PrefetchHooks Function()
    >;
typedef $$ChartOfAccountsTableCreateCompanionBuilder =
    ChartOfAccountsCompanion Function({
      required String id,
      required String storeId,
      required String code,
      required String name,
      required String type,
      Value<String?> parentAccountId,
      Value<bool> isSystemAccount,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$ChartOfAccountsTableUpdateCompanionBuilder =
    ChartOfAccountsCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> code,
      Value<String> name,
      Value<String> type,
      Value<String?> parentAccountId,
      Value<bool> isSystemAccount,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$ChartOfAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $ChartOfAccountsTable> {
  $$ChartOfAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentAccountId => $composableBuilder(
    column: $table.parentAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystemAccount => $composableBuilder(
    column: $table.isSystemAccount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChartOfAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChartOfAccountsTable> {
  $$ChartOfAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentAccountId => $composableBuilder(
    column: $table.parentAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystemAccount => $composableBuilder(
    column: $table.isSystemAccount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChartOfAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChartOfAccountsTable> {
  $$ChartOfAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get parentAccountId => $composableBuilder(
    column: $table.parentAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSystemAccount => $composableBuilder(
    column: $table.isSystemAccount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$ChartOfAccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChartOfAccountsTable,
          ChartOfAccount,
          $$ChartOfAccountsTableFilterComposer,
          $$ChartOfAccountsTableOrderingComposer,
          $$ChartOfAccountsTableAnnotationComposer,
          $$ChartOfAccountsTableCreateCompanionBuilder,
          $$ChartOfAccountsTableUpdateCompanionBuilder,
          (
            ChartOfAccount,
            BaseReferences<
              _$AppDatabase,
              $ChartOfAccountsTable,
              ChartOfAccount
            >,
          ),
          ChartOfAccount,
          PrefetchHooks Function()
        > {
  $$ChartOfAccountsTableTableManager(
    _$AppDatabase db,
    $ChartOfAccountsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChartOfAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChartOfAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChartOfAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> parentAccountId = const Value.absent(),
                Value<bool> isSystemAccount = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChartOfAccountsCompanion(
                id: id,
                storeId: storeId,
                code: code,
                name: name,
                type: type,
                parentAccountId: parentAccountId,
                isSystemAccount: isSystemAccount,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String code,
                required String name,
                required String type,
                Value<String?> parentAccountId = const Value.absent(),
                Value<bool> isSystemAccount = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChartOfAccountsCompanion.insert(
                id: id,
                storeId: storeId,
                code: code,
                name: name,
                type: type,
                parentAccountId: parentAccountId,
                isSystemAccount: isSystemAccount,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChartOfAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChartOfAccountsTable,
      ChartOfAccount,
      $$ChartOfAccountsTableFilterComposer,
      $$ChartOfAccountsTableOrderingComposer,
      $$ChartOfAccountsTableAnnotationComposer,
      $$ChartOfAccountsTableCreateCompanionBuilder,
      $$ChartOfAccountsTableUpdateCompanionBuilder,
      (
        ChartOfAccount,
        BaseReferences<_$AppDatabase, $ChartOfAccountsTable, ChartOfAccount>,
      ),
      ChartOfAccount,
      PrefetchHooks Function()
    >;
typedef $$JournalEntriesTableCreateCompanionBuilder =
    JournalEntriesCompanion Function({
      required String id,
      required String storeId,
      required String branchId,
      required DateTime entryDate,
      required String referenceType,
      Value<String?> referenceId,
      Value<String> memo,
      required String createdByUserId,
      Value<bool> isReversal,
      Value<String?> reversalOfEntryId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$JournalEntriesTableUpdateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> branchId,
      Value<DateTime> entryDate,
      Value<String> referenceType,
      Value<String?> referenceId,
      Value<String> memo,
      Value<String> createdByUserId,
      Value<bool> isReversal,
      Value<String?> reversalOfEntryId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$JournalEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceType => $composableBuilder(
    column: $table.referenceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isReversal => $composableBuilder(
    column: $table.isReversal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reversalOfEntryId => $composableBuilder(
    column: $table.reversalOfEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JournalEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceType => $composableBuilder(
    column: $table.referenceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isReversal => $composableBuilder(
    column: $table.isReversal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reversalOfEntryId => $composableBuilder(
    column: $table.reversalOfEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<DateTime> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<String> get referenceType => $composableBuilder(
    column: $table.referenceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<String> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isReversal => $composableBuilder(
    column: $table.isReversal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reversalOfEntryId => $composableBuilder(
    column: $table.reversalOfEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$JournalEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JournalEntriesTable,
          JournalEntry,
          $$JournalEntriesTableFilterComposer,
          $$JournalEntriesTableOrderingComposer,
          $$JournalEntriesTableAnnotationComposer,
          $$JournalEntriesTableCreateCompanionBuilder,
          $$JournalEntriesTableUpdateCompanionBuilder,
          (
            JournalEntry,
            BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntry>,
          ),
          JournalEntry,
          PrefetchHooks Function()
        > {
  $$JournalEntriesTableTableManager(
    _$AppDatabase db,
    $JournalEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> branchId = const Value.absent(),
                Value<DateTime> entryDate = const Value.absent(),
                Value<String> referenceType = const Value.absent(),
                Value<String?> referenceId = const Value.absent(),
                Value<String> memo = const Value.absent(),
                Value<String> createdByUserId = const Value.absent(),
                Value<bool> isReversal = const Value.absent(),
                Value<String?> reversalOfEntryId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion(
                id: id,
                storeId: storeId,
                branchId: branchId,
                entryDate: entryDate,
                referenceType: referenceType,
                referenceId: referenceId,
                memo: memo,
                createdByUserId: createdByUserId,
                isReversal: isReversal,
                reversalOfEntryId: reversalOfEntryId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String branchId,
                required DateTime entryDate,
                required String referenceType,
                Value<String?> referenceId = const Value.absent(),
                Value<String> memo = const Value.absent(),
                required String createdByUserId,
                Value<bool> isReversal = const Value.absent(),
                Value<String?> reversalOfEntryId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion.insert(
                id: id,
                storeId: storeId,
                branchId: branchId,
                entryDate: entryDate,
                referenceType: referenceType,
                referenceId: referenceId,
                memo: memo,
                createdByUserId: createdByUserId,
                isReversal: isReversal,
                reversalOfEntryId: reversalOfEntryId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JournalEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JournalEntriesTable,
      JournalEntry,
      $$JournalEntriesTableFilterComposer,
      $$JournalEntriesTableOrderingComposer,
      $$JournalEntriesTableAnnotationComposer,
      $$JournalEntriesTableCreateCompanionBuilder,
      $$JournalEntriesTableUpdateCompanionBuilder,
      (
        JournalEntry,
        BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntry>,
      ),
      JournalEntry,
      PrefetchHooks Function()
    >;
typedef $$JournalLinesTableCreateCompanionBuilder =
    JournalLinesCompanion Function({
      required String id,
      required String storeId,
      required String journalEntryId,
      required String accountId,
      Value<int> debitMinorUnits,
      Value<int> creditMinorUnits,
      Value<String> description,
      Value<int> rowid,
    });
typedef $$JournalLinesTableUpdateCompanionBuilder =
    JournalLinesCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> journalEntryId,
      Value<String> accountId,
      Value<int> debitMinorUnits,
      Value<int> creditMinorUnits,
      Value<String> description,
      Value<int> rowid,
    });

class $$JournalLinesTableFilterComposer
    extends Composer<_$AppDatabase, $JournalLinesTable> {
  $$JournalLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get debitMinorUnits => $composableBuilder(
    column: $table.debitMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creditMinorUnits => $composableBuilder(
    column: $table.creditMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JournalLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalLinesTable> {
  $$JournalLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get debitMinorUnits => $composableBuilder(
    column: $table.debitMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creditMinorUnits => $composableBuilder(
    column: $table.creditMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalLinesTable> {
  $$JournalLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get debitMinorUnits => $composableBuilder(
    column: $table.debitMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get creditMinorUnits => $composableBuilder(
    column: $table.creditMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );
}

class $$JournalLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JournalLinesTable,
          JournalLine,
          $$JournalLinesTableFilterComposer,
          $$JournalLinesTableOrderingComposer,
          $$JournalLinesTableAnnotationComposer,
          $$JournalLinesTableCreateCompanionBuilder,
          $$JournalLinesTableUpdateCompanionBuilder,
          (
            JournalLine,
            BaseReferences<_$AppDatabase, $JournalLinesTable, JournalLine>,
          ),
          JournalLine,
          PrefetchHooks Function()
        > {
  $$JournalLinesTableTableManager(_$AppDatabase db, $JournalLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> journalEntryId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<int> debitMinorUnits = const Value.absent(),
                Value<int> creditMinorUnits = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalLinesCompanion(
                id: id,
                storeId: storeId,
                journalEntryId: journalEntryId,
                accountId: accountId,
                debitMinorUnits: debitMinorUnits,
                creditMinorUnits: creditMinorUnits,
                description: description,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String journalEntryId,
                required String accountId,
                Value<int> debitMinorUnits = const Value.absent(),
                Value<int> creditMinorUnits = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalLinesCompanion.insert(
                id: id,
                storeId: storeId,
                journalEntryId: journalEntryId,
                accountId: accountId,
                debitMinorUnits: debitMinorUnits,
                creditMinorUnits: creditMinorUnits,
                description: description,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JournalLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JournalLinesTable,
      JournalLine,
      $$JournalLinesTableFilterComposer,
      $$JournalLinesTableOrderingComposer,
      $$JournalLinesTableAnnotationComposer,
      $$JournalLinesTableCreateCompanionBuilder,
      $$JournalLinesTableUpdateCompanionBuilder,
      (
        JournalLine,
        BaseReferences<_$AppDatabase, $JournalLinesTable, JournalLine>,
      ),
      JournalLine,
      PrefetchHooks Function()
    >;
typedef $$SalesTableCreateCompanionBuilder =
    SalesCompanion Function({
      required String id,
      required String storeId,
      required String branchId,
      required String saleNumber,
      required String status,
      Value<String?> customerId,
      Value<String?> holdLabel,
      Value<int> subtotalMinorUnits,
      Value<int> discountTotalMinorUnits,
      Value<int> taxTotalMinorUnits,
      Value<int> grandTotalMinorUnits,
      Value<String?> paymentMethod,
      Value<int?> amountTenderedMinorUnits,
      Value<int?> changeGivenMinorUnits,
      Value<String?> shiftId,
      required String cashierId,
      Value<String?> journalEntryId,
      required DateTime createdAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$SalesTableUpdateCompanionBuilder =
    SalesCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> branchId,
      Value<String> saleNumber,
      Value<String> status,
      Value<String?> customerId,
      Value<String?> holdLabel,
      Value<int> subtotalMinorUnits,
      Value<int> discountTotalMinorUnits,
      Value<int> taxTotalMinorUnits,
      Value<int> grandTotalMinorUnits,
      Value<String?> paymentMethod,
      Value<int?> amountTenderedMinorUnits,
      Value<int?> changeGivenMinorUnits,
      Value<String?> shiftId,
      Value<String> cashierId,
      Value<String?> journalEntryId,
      Value<DateTime> createdAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saleNumber => $composableBuilder(
    column: $table.saleNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get holdLabel => $composableBuilder(
    column: $table.holdLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get subtotalMinorUnits => $composableBuilder(
    column: $table.subtotalMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountTotalMinorUnits => $composableBuilder(
    column: $table.discountTotalMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taxTotalMinorUnits => $composableBuilder(
    column: $table.taxTotalMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grandTotalMinorUnits => $composableBuilder(
    column: $table.grandTotalMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountTenderedMinorUnits => $composableBuilder(
    column: $table.amountTenderedMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get changeGivenMinorUnits => $composableBuilder(
    column: $table.changeGivenMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cashierId => $composableBuilder(
    column: $table.cashierId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SalesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saleNumber => $composableBuilder(
    column: $table.saleNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get holdLabel => $composableBuilder(
    column: $table.holdLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subtotalMinorUnits => $composableBuilder(
    column: $table.subtotalMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountTotalMinorUnits => $composableBuilder(
    column: $table.discountTotalMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taxTotalMinorUnits => $composableBuilder(
    column: $table.taxTotalMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grandTotalMinorUnits => $composableBuilder(
    column: $table.grandTotalMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountTenderedMinorUnits => $composableBuilder(
    column: $table.amountTenderedMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get changeGivenMinorUnits => $composableBuilder(
    column: $table.changeGivenMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cashierId => $composableBuilder(
    column: $table.cashierId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get saleNumber => $composableBuilder(
    column: $table.saleNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get holdLabel =>
      $composableBuilder(column: $table.holdLabel, builder: (column) => column);

  GeneratedColumn<int> get subtotalMinorUnits => $composableBuilder(
    column: $table.subtotalMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discountTotalMinorUnits => $composableBuilder(
    column: $table.discountTotalMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get taxTotalMinorUnits => $composableBuilder(
    column: $table.taxTotalMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get grandTotalMinorUnits => $composableBuilder(
    column: $table.grandTotalMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountTenderedMinorUnits => $composableBuilder(
    column: $table.amountTenderedMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get changeGivenMinorUnits => $composableBuilder(
    column: $table.changeGivenMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shiftId =>
      $composableBuilder(column: $table.shiftId, builder: (column) => column);

  GeneratedColumn<String> get cashierId =>
      $composableBuilder(column: $table.cashierId, builder: (column) => column);

  GeneratedColumn<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$SalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesTable,
          Sale,
          $$SalesTableFilterComposer,
          $$SalesTableOrderingComposer,
          $$SalesTableAnnotationComposer,
          $$SalesTableCreateCompanionBuilder,
          $$SalesTableUpdateCompanionBuilder,
          (Sale, BaseReferences<_$AppDatabase, $SalesTable, Sale>),
          Sale,
          PrefetchHooks Function()
        > {
  $$SalesTableTableManager(_$AppDatabase db, $SalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> branchId = const Value.absent(),
                Value<String> saleNumber = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String?> holdLabel = const Value.absent(),
                Value<int> subtotalMinorUnits = const Value.absent(),
                Value<int> discountTotalMinorUnits = const Value.absent(),
                Value<int> taxTotalMinorUnits = const Value.absent(),
                Value<int> grandTotalMinorUnits = const Value.absent(),
                Value<String?> paymentMethod = const Value.absent(),
                Value<int?> amountTenderedMinorUnits = const Value.absent(),
                Value<int?> changeGivenMinorUnits = const Value.absent(),
                Value<String?> shiftId = const Value.absent(),
                Value<String> cashierId = const Value.absent(),
                Value<String?> journalEntryId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion(
                id: id,
                storeId: storeId,
                branchId: branchId,
                saleNumber: saleNumber,
                status: status,
                customerId: customerId,
                holdLabel: holdLabel,
                subtotalMinorUnits: subtotalMinorUnits,
                discountTotalMinorUnits: discountTotalMinorUnits,
                taxTotalMinorUnits: taxTotalMinorUnits,
                grandTotalMinorUnits: grandTotalMinorUnits,
                paymentMethod: paymentMethod,
                amountTenderedMinorUnits: amountTenderedMinorUnits,
                changeGivenMinorUnits: changeGivenMinorUnits,
                shiftId: shiftId,
                cashierId: cashierId,
                journalEntryId: journalEntryId,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String branchId,
                required String saleNumber,
                required String status,
                Value<String?> customerId = const Value.absent(),
                Value<String?> holdLabel = const Value.absent(),
                Value<int> subtotalMinorUnits = const Value.absent(),
                Value<int> discountTotalMinorUnits = const Value.absent(),
                Value<int> taxTotalMinorUnits = const Value.absent(),
                Value<int> grandTotalMinorUnits = const Value.absent(),
                Value<String?> paymentMethod = const Value.absent(),
                Value<int?> amountTenderedMinorUnits = const Value.absent(),
                Value<int?> changeGivenMinorUnits = const Value.absent(),
                Value<String?> shiftId = const Value.absent(),
                required String cashierId,
                Value<String?> journalEntryId = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion.insert(
                id: id,
                storeId: storeId,
                branchId: branchId,
                saleNumber: saleNumber,
                status: status,
                customerId: customerId,
                holdLabel: holdLabel,
                subtotalMinorUnits: subtotalMinorUnits,
                discountTotalMinorUnits: discountTotalMinorUnits,
                taxTotalMinorUnits: taxTotalMinorUnits,
                grandTotalMinorUnits: grandTotalMinorUnits,
                paymentMethod: paymentMethod,
                amountTenderedMinorUnits: amountTenderedMinorUnits,
                changeGivenMinorUnits: changeGivenMinorUnits,
                shiftId: shiftId,
                cashierId: cashierId,
                journalEntryId: journalEntryId,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesTable,
      Sale,
      $$SalesTableFilterComposer,
      $$SalesTableOrderingComposer,
      $$SalesTableAnnotationComposer,
      $$SalesTableCreateCompanionBuilder,
      $$SalesTableUpdateCompanionBuilder,
      (Sale, BaseReferences<_$AppDatabase, $SalesTable, Sale>),
      Sale,
      PrefetchHooks Function()
    >;
typedef $$SaleLinesTableCreateCompanionBuilder =
    SaleLinesCompanion Function({
      required String id,
      required String saleId,
      required String productId,
      required int quantity,
      required int unitPriceMinorUnits,
      Value<int> discountAmountMinorUnits,
      Value<int> taxAmountMinorUnits,
      required int lineTotalMinorUnits,
      Value<int> costPriceSnapshotMinorUnits,
      Value<int> rowid,
    });
typedef $$SaleLinesTableUpdateCompanionBuilder =
    SaleLinesCompanion Function({
      Value<String> id,
      Value<String> saleId,
      Value<String> productId,
      Value<int> quantity,
      Value<int> unitPriceMinorUnits,
      Value<int> discountAmountMinorUnits,
      Value<int> taxAmountMinorUnits,
      Value<int> lineTotalMinorUnits,
      Value<int> costPriceSnapshotMinorUnits,
      Value<int> rowid,
    });

class $$SaleLinesTableFilterComposer
    extends Composer<_$AppDatabase, $SaleLinesTable> {
  $$SaleLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPriceMinorUnits => $composableBuilder(
    column: $table.unitPriceMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountAmountMinorUnits => $composableBuilder(
    column: $table.discountAmountMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taxAmountMinorUnits => $composableBuilder(
    column: $table.taxAmountMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineTotalMinorUnits => $composableBuilder(
    column: $table.lineTotalMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get costPriceSnapshotMinorUnits => $composableBuilder(
    column: $table.costPriceSnapshotMinorUnits,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SaleLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleLinesTable> {
  $$SaleLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPriceMinorUnits => $composableBuilder(
    column: $table.unitPriceMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountAmountMinorUnits => $composableBuilder(
    column: $table.discountAmountMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taxAmountMinorUnits => $composableBuilder(
    column: $table.taxAmountMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineTotalMinorUnits => $composableBuilder(
    column: $table.lineTotalMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get costPriceSnapshotMinorUnits => $composableBuilder(
    column: $table.costPriceSnapshotMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SaleLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleLinesTable> {
  $$SaleLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get unitPriceMinorUnits => $composableBuilder(
    column: $table.unitPriceMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discountAmountMinorUnits => $composableBuilder(
    column: $table.discountAmountMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get taxAmountMinorUnits => $composableBuilder(
    column: $table.taxAmountMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lineTotalMinorUnits => $composableBuilder(
    column: $table.lineTotalMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get costPriceSnapshotMinorUnits => $composableBuilder(
    column: $table.costPriceSnapshotMinorUnits,
    builder: (column) => column,
  );
}

class $$SaleLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleLinesTable,
          SaleLine,
          $$SaleLinesTableFilterComposer,
          $$SaleLinesTableOrderingComposer,
          $$SaleLinesTableAnnotationComposer,
          $$SaleLinesTableCreateCompanionBuilder,
          $$SaleLinesTableUpdateCompanionBuilder,
          (SaleLine, BaseReferences<_$AppDatabase, $SaleLinesTable, SaleLine>),
          SaleLine,
          PrefetchHooks Function()
        > {
  $$SaleLinesTableTableManager(_$AppDatabase db, $SaleLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> saleId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> unitPriceMinorUnits = const Value.absent(),
                Value<int> discountAmountMinorUnits = const Value.absent(),
                Value<int> taxAmountMinorUnits = const Value.absent(),
                Value<int> lineTotalMinorUnits = const Value.absent(),
                Value<int> costPriceSnapshotMinorUnits = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleLinesCompanion(
                id: id,
                saleId: saleId,
                productId: productId,
                quantity: quantity,
                unitPriceMinorUnits: unitPriceMinorUnits,
                discountAmountMinorUnits: discountAmountMinorUnits,
                taxAmountMinorUnits: taxAmountMinorUnits,
                lineTotalMinorUnits: lineTotalMinorUnits,
                costPriceSnapshotMinorUnits: costPriceSnapshotMinorUnits,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String saleId,
                required String productId,
                required int quantity,
                required int unitPriceMinorUnits,
                Value<int> discountAmountMinorUnits = const Value.absent(),
                Value<int> taxAmountMinorUnits = const Value.absent(),
                required int lineTotalMinorUnits,
                Value<int> costPriceSnapshotMinorUnits = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleLinesCompanion.insert(
                id: id,
                saleId: saleId,
                productId: productId,
                quantity: quantity,
                unitPriceMinorUnits: unitPriceMinorUnits,
                discountAmountMinorUnits: discountAmountMinorUnits,
                taxAmountMinorUnits: taxAmountMinorUnits,
                lineTotalMinorUnits: lineTotalMinorUnits,
                costPriceSnapshotMinorUnits: costPriceSnapshotMinorUnits,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SaleLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleLinesTable,
      SaleLine,
      $$SaleLinesTableFilterComposer,
      $$SaleLinesTableOrderingComposer,
      $$SaleLinesTableAnnotationComposer,
      $$SaleLinesTableCreateCompanionBuilder,
      $$SaleLinesTableUpdateCompanionBuilder,
      (SaleLine, BaseReferences<_$AppDatabase, $SaleLinesTable, SaleLine>),
      SaleLine,
      PrefetchHooks Function()
    >;
typedef $$SaleReturnsTableCreateCompanionBuilder =
    SaleReturnsCompanion Function({
      required String id,
      required String storeId,
      required String branchId,
      required String originalSaleId,
      required String refundMethod,
      Value<String?> journalEntryId,
      required String processedByUserId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SaleReturnsTableUpdateCompanionBuilder =
    SaleReturnsCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> branchId,
      Value<String> originalSaleId,
      Value<String> refundMethod,
      Value<String?> journalEntryId,
      Value<String> processedByUserId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SaleReturnsTableFilterComposer
    extends Composer<_$AppDatabase, $SaleReturnsTable> {
  $$SaleReturnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalSaleId => $composableBuilder(
    column: $table.originalSaleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refundMethod => $composableBuilder(
    column: $table.refundMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get processedByUserId => $composableBuilder(
    column: $table.processedByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SaleReturnsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleReturnsTable> {
  $$SaleReturnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalSaleId => $composableBuilder(
    column: $table.originalSaleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refundMethod => $composableBuilder(
    column: $table.refundMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get processedByUserId => $composableBuilder(
    column: $table.processedByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SaleReturnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleReturnsTable> {
  $$SaleReturnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get originalSaleId => $composableBuilder(
    column: $table.originalSaleId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get refundMethod => $composableBuilder(
    column: $table.refundMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get processedByUserId => $composableBuilder(
    column: $table.processedByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SaleReturnsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleReturnsTable,
          SaleReturn,
          $$SaleReturnsTableFilterComposer,
          $$SaleReturnsTableOrderingComposer,
          $$SaleReturnsTableAnnotationComposer,
          $$SaleReturnsTableCreateCompanionBuilder,
          $$SaleReturnsTableUpdateCompanionBuilder,
          (
            SaleReturn,
            BaseReferences<_$AppDatabase, $SaleReturnsTable, SaleReturn>,
          ),
          SaleReturn,
          PrefetchHooks Function()
        > {
  $$SaleReturnsTableTableManager(_$AppDatabase db, $SaleReturnsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleReturnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleReturnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleReturnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> branchId = const Value.absent(),
                Value<String> originalSaleId = const Value.absent(),
                Value<String> refundMethod = const Value.absent(),
                Value<String?> journalEntryId = const Value.absent(),
                Value<String> processedByUserId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleReturnsCompanion(
                id: id,
                storeId: storeId,
                branchId: branchId,
                originalSaleId: originalSaleId,
                refundMethod: refundMethod,
                journalEntryId: journalEntryId,
                processedByUserId: processedByUserId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String branchId,
                required String originalSaleId,
                required String refundMethod,
                Value<String?> journalEntryId = const Value.absent(),
                required String processedByUserId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SaleReturnsCompanion.insert(
                id: id,
                storeId: storeId,
                branchId: branchId,
                originalSaleId: originalSaleId,
                refundMethod: refundMethod,
                journalEntryId: journalEntryId,
                processedByUserId: processedByUserId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SaleReturnsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleReturnsTable,
      SaleReturn,
      $$SaleReturnsTableFilterComposer,
      $$SaleReturnsTableOrderingComposer,
      $$SaleReturnsTableAnnotationComposer,
      $$SaleReturnsTableCreateCompanionBuilder,
      $$SaleReturnsTableUpdateCompanionBuilder,
      (
        SaleReturn,
        BaseReferences<_$AppDatabase, $SaleReturnsTable, SaleReturn>,
      ),
      SaleReturn,
      PrefetchHooks Function()
    >;
typedef $$SaleReturnLinesTableCreateCompanionBuilder =
    SaleReturnLinesCompanion Function({
      required String id,
      required String saleReturnId,
      required String saleLineId,
      required int quantityReturned,
      required int refundAmountMinorUnits,
      Value<int> rowid,
    });
typedef $$SaleReturnLinesTableUpdateCompanionBuilder =
    SaleReturnLinesCompanion Function({
      Value<String> id,
      Value<String> saleReturnId,
      Value<String> saleLineId,
      Value<int> quantityReturned,
      Value<int> refundAmountMinorUnits,
      Value<int> rowid,
    });

class $$SaleReturnLinesTableFilterComposer
    extends Composer<_$AppDatabase, $SaleReturnLinesTable> {
  $$SaleReturnLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saleReturnId => $composableBuilder(
    column: $table.saleReturnId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saleLineId => $composableBuilder(
    column: $table.saleLineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityReturned => $composableBuilder(
    column: $table.quantityReturned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refundAmountMinorUnits => $composableBuilder(
    column: $table.refundAmountMinorUnits,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SaleReturnLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleReturnLinesTable> {
  $$SaleReturnLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saleReturnId => $composableBuilder(
    column: $table.saleReturnId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saleLineId => $composableBuilder(
    column: $table.saleLineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityReturned => $composableBuilder(
    column: $table.quantityReturned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refundAmountMinorUnits => $composableBuilder(
    column: $table.refundAmountMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SaleReturnLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleReturnLinesTable> {
  $$SaleReturnLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saleReturnId => $composableBuilder(
    column: $table.saleReturnId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get saleLineId => $composableBuilder(
    column: $table.saleLineId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantityReturned => $composableBuilder(
    column: $table.quantityReturned,
    builder: (column) => column,
  );

  GeneratedColumn<int> get refundAmountMinorUnits => $composableBuilder(
    column: $table.refundAmountMinorUnits,
    builder: (column) => column,
  );
}

class $$SaleReturnLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleReturnLinesTable,
          SaleReturnLine,
          $$SaleReturnLinesTableFilterComposer,
          $$SaleReturnLinesTableOrderingComposer,
          $$SaleReturnLinesTableAnnotationComposer,
          $$SaleReturnLinesTableCreateCompanionBuilder,
          $$SaleReturnLinesTableUpdateCompanionBuilder,
          (
            SaleReturnLine,
            BaseReferences<
              _$AppDatabase,
              $SaleReturnLinesTable,
              SaleReturnLine
            >,
          ),
          SaleReturnLine,
          PrefetchHooks Function()
        > {
  $$SaleReturnLinesTableTableManager(
    _$AppDatabase db,
    $SaleReturnLinesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleReturnLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleReturnLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleReturnLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> saleReturnId = const Value.absent(),
                Value<String> saleLineId = const Value.absent(),
                Value<int> quantityReturned = const Value.absent(),
                Value<int> refundAmountMinorUnits = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleReturnLinesCompanion(
                id: id,
                saleReturnId: saleReturnId,
                saleLineId: saleLineId,
                quantityReturned: quantityReturned,
                refundAmountMinorUnits: refundAmountMinorUnits,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String saleReturnId,
                required String saleLineId,
                required int quantityReturned,
                required int refundAmountMinorUnits,
                Value<int> rowid = const Value.absent(),
              }) => SaleReturnLinesCompanion.insert(
                id: id,
                saleReturnId: saleReturnId,
                saleLineId: saleLineId,
                quantityReturned: quantityReturned,
                refundAmountMinorUnits: refundAmountMinorUnits,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SaleReturnLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleReturnLinesTable,
      SaleReturnLine,
      $$SaleReturnLinesTableFilterComposer,
      $$SaleReturnLinesTableOrderingComposer,
      $$SaleReturnLinesTableAnnotationComposer,
      $$SaleReturnLinesTableCreateCompanionBuilder,
      $$SaleReturnLinesTableUpdateCompanionBuilder,
      (
        SaleReturnLine,
        BaseReferences<_$AppDatabase, $SaleReturnLinesTable, SaleReturnLine>,
      ),
      SaleReturnLine,
      PrefetchHooks Function()
    >;
typedef $$ShiftsTableCreateCompanionBuilder =
    ShiftsCompanion Function({
      required String id,
      required String storeId,
      required String branchId,
      required String cashierId,
      required DateTime openedAt,
      Value<DateTime?> closedAt,
      Value<int> openingCashFloatMinorUnits,
      Value<int?> expectedCashAtCloseMinorUnits,
      Value<int?> countedCashAtCloseMinorUnits,
      Value<int?> discrepancyMinorUnits,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$ShiftsTableUpdateCompanionBuilder =
    ShiftsCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> branchId,
      Value<String> cashierId,
      Value<DateTime> openedAt,
      Value<DateTime?> closedAt,
      Value<int> openingCashFloatMinorUnits,
      Value<int?> expectedCashAtCloseMinorUnits,
      Value<int?> countedCashAtCloseMinorUnits,
      Value<int?> discrepancyMinorUnits,
      Value<String> status,
      Value<int> rowid,
    });

class $$ShiftsTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cashierId => $composableBuilder(
    column: $table.cashierId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openingCashFloatMinorUnits => $composableBuilder(
    column: $table.openingCashFloatMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedCashAtCloseMinorUnits => $composableBuilder(
    column: $table.expectedCashAtCloseMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get countedCashAtCloseMinorUnits => $composableBuilder(
    column: $table.countedCashAtCloseMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discrepancyMinorUnits => $composableBuilder(
    column: $table.discrepancyMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShiftsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cashierId => $composableBuilder(
    column: $table.cashierId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingCashFloatMinorUnits => $composableBuilder(
    column: $table.openingCashFloatMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedCashAtCloseMinorUnits => $composableBuilder(
    column: $table.expectedCashAtCloseMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get countedCashAtCloseMinorUnits => $composableBuilder(
    column: $table.countedCashAtCloseMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discrepancyMinorUnits => $composableBuilder(
    column: $table.discrepancyMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShiftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get cashierId =>
      $composableBuilder(column: $table.cashierId, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<int> get openingCashFloatMinorUnits => $composableBuilder(
    column: $table.openingCashFloatMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expectedCashAtCloseMinorUnits => $composableBuilder(
    column: $table.expectedCashAtCloseMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get countedCashAtCloseMinorUnits => $composableBuilder(
    column: $table.countedCashAtCloseMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discrepancyMinorUnits => $composableBuilder(
    column: $table.discrepancyMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$ShiftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShiftsTable,
          Shift,
          $$ShiftsTableFilterComposer,
          $$ShiftsTableOrderingComposer,
          $$ShiftsTableAnnotationComposer,
          $$ShiftsTableCreateCompanionBuilder,
          $$ShiftsTableUpdateCompanionBuilder,
          (Shift, BaseReferences<_$AppDatabase, $ShiftsTable, Shift>),
          Shift,
          PrefetchHooks Function()
        > {
  $$ShiftsTableTableManager(_$AppDatabase db, $ShiftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShiftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShiftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShiftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> branchId = const Value.absent(),
                Value<String> cashierId = const Value.absent(),
                Value<DateTime> openedAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<int> openingCashFloatMinorUnits = const Value.absent(),
                Value<int?> expectedCashAtCloseMinorUnits =
                    const Value.absent(),
                Value<int?> countedCashAtCloseMinorUnits = const Value.absent(),
                Value<int?> discrepancyMinorUnits = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftsCompanion(
                id: id,
                storeId: storeId,
                branchId: branchId,
                cashierId: cashierId,
                openedAt: openedAt,
                closedAt: closedAt,
                openingCashFloatMinorUnits: openingCashFloatMinorUnits,
                expectedCashAtCloseMinorUnits: expectedCashAtCloseMinorUnits,
                countedCashAtCloseMinorUnits: countedCashAtCloseMinorUnits,
                discrepancyMinorUnits: discrepancyMinorUnits,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String branchId,
                required String cashierId,
                required DateTime openedAt,
                Value<DateTime?> closedAt = const Value.absent(),
                Value<int> openingCashFloatMinorUnits = const Value.absent(),
                Value<int?> expectedCashAtCloseMinorUnits =
                    const Value.absent(),
                Value<int?> countedCashAtCloseMinorUnits = const Value.absent(),
                Value<int?> discrepancyMinorUnits = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftsCompanion.insert(
                id: id,
                storeId: storeId,
                branchId: branchId,
                cashierId: cashierId,
                openedAt: openedAt,
                closedAt: closedAt,
                openingCashFloatMinorUnits: openingCashFloatMinorUnits,
                expectedCashAtCloseMinorUnits: expectedCashAtCloseMinorUnits,
                countedCashAtCloseMinorUnits: countedCashAtCloseMinorUnits,
                discrepancyMinorUnits: discrepancyMinorUnits,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShiftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShiftsTable,
      Shift,
      $$ShiftsTableFilterComposer,
      $$ShiftsTableOrderingComposer,
      $$ShiftsTableAnnotationComposer,
      $$ShiftsTableCreateCompanionBuilder,
      $$ShiftsTableUpdateCompanionBuilder,
      (Shift, BaseReferences<_$AppDatabase, $ShiftsTable, Shift>),
      Shift,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableTableCreateCompanionBuilder =
    AppSettingsTableCompanion Function({
      required String id,
      required String storeId,
      Value<String> defaultLanguage,
      Value<String> themeMode,
      Value<String> currencyCode,
      Value<String> currencySymbol,
      Value<double> defaultVatRatePercent,
      Value<String> printerConfigJson,
      Value<bool> autoBackupEnabled,
      Value<String> autoBackupTimeOfDay,
      Value<String?> autoBackupFolderPath,
      Value<int> lowStockThresholdDefault,
      Value<int> rowid,
    });
typedef $$AppSettingsTableTableUpdateCompanionBuilder =
    AppSettingsTableCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> defaultLanguage,
      Value<String> themeMode,
      Value<String> currencyCode,
      Value<String> currencySymbol,
      Value<double> defaultVatRatePercent,
      Value<String> printerConfigJson,
      Value<bool> autoBackupEnabled,
      Value<String> autoBackupTimeOfDay,
      Value<String?> autoBackupFolderPath,
      Value<int> lowStockThresholdDefault,
      Value<int> rowid,
    });

class $$AppSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultLanguage => $composableBuilder(
    column: $table.defaultLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencySymbol => $composableBuilder(
    column: $table.currencySymbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultVatRatePercent => $composableBuilder(
    column: $table.defaultVatRatePercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get printerConfigJson => $composableBuilder(
    column: $table.printerConfigJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoBackupEnabled => $composableBuilder(
    column: $table.autoBackupEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get autoBackupTimeOfDay => $composableBuilder(
    column: $table.autoBackupTimeOfDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get autoBackupFolderPath => $composableBuilder(
    column: $table.autoBackupFolderPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lowStockThresholdDefault => $composableBuilder(
    column: $table.lowStockThresholdDefault,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultLanguage => $composableBuilder(
    column: $table.defaultLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencySymbol => $composableBuilder(
    column: $table.currencySymbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultVatRatePercent => $composableBuilder(
    column: $table.defaultVatRatePercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get printerConfigJson => $composableBuilder(
    column: $table.printerConfigJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoBackupEnabled => $composableBuilder(
    column: $table.autoBackupEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get autoBackupTimeOfDay => $composableBuilder(
    column: $table.autoBackupTimeOfDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get autoBackupFolderPath => $composableBuilder(
    column: $table.autoBackupFolderPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lowStockThresholdDefault => $composableBuilder(
    column: $table.lowStockThresholdDefault,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get defaultLanguage => $composableBuilder(
    column: $table.defaultLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencySymbol => $composableBuilder(
    column: $table.currencySymbol,
    builder: (column) => column,
  );

  GeneratedColumn<double> get defaultVatRatePercent => $composableBuilder(
    column: $table.defaultVatRatePercent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get printerConfigJson => $composableBuilder(
    column: $table.printerConfigJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoBackupEnabled => $composableBuilder(
    column: $table.autoBackupEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get autoBackupTimeOfDay => $composableBuilder(
    column: $table.autoBackupTimeOfDay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get autoBackupFolderPath => $composableBuilder(
    column: $table.autoBackupFolderPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lowStockThresholdDefault => $composableBuilder(
    column: $table.lowStockThresholdDefault,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSettingsTableData,
          $$AppSettingsTableTableFilterComposer,
          $$AppSettingsTableTableOrderingComposer,
          $$AppSettingsTableTableAnnotationComposer,
          $$AppSettingsTableTableCreateCompanionBuilder,
          $$AppSettingsTableTableUpdateCompanionBuilder,
          (
            AppSettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $AppSettingsTableTable,
              AppSettingsTableData
            >,
          ),
          AppSettingsTableData,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableTableManager(
    _$AppDatabase db,
    $AppSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> defaultLanguage = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> currencySymbol = const Value.absent(),
                Value<double> defaultVatRatePercent = const Value.absent(),
                Value<String> printerConfigJson = const Value.absent(),
                Value<bool> autoBackupEnabled = const Value.absent(),
                Value<String> autoBackupTimeOfDay = const Value.absent(),
                Value<String?> autoBackupFolderPath = const Value.absent(),
                Value<int> lowStockThresholdDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsTableCompanion(
                id: id,
                storeId: storeId,
                defaultLanguage: defaultLanguage,
                themeMode: themeMode,
                currencyCode: currencyCode,
                currencySymbol: currencySymbol,
                defaultVatRatePercent: defaultVatRatePercent,
                printerConfigJson: printerConfigJson,
                autoBackupEnabled: autoBackupEnabled,
                autoBackupTimeOfDay: autoBackupTimeOfDay,
                autoBackupFolderPath: autoBackupFolderPath,
                lowStockThresholdDefault: lowStockThresholdDefault,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                Value<String> defaultLanguage = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> currencySymbol = const Value.absent(),
                Value<double> defaultVatRatePercent = const Value.absent(),
                Value<String> printerConfigJson = const Value.absent(),
                Value<bool> autoBackupEnabled = const Value.absent(),
                Value<String> autoBackupTimeOfDay = const Value.absent(),
                Value<String?> autoBackupFolderPath = const Value.absent(),
                Value<int> lowStockThresholdDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsTableCompanion.insert(
                id: id,
                storeId: storeId,
                defaultLanguage: defaultLanguage,
                themeMode: themeMode,
                currencyCode: currencyCode,
                currencySymbol: currencySymbol,
                defaultVatRatePercent: defaultVatRatePercent,
                printerConfigJson: printerConfigJson,
                autoBackupEnabled: autoBackupEnabled,
                autoBackupTimeOfDay: autoBackupTimeOfDay,
                autoBackupFolderPath: autoBackupFolderPath,
                lowStockThresholdDefault: lowStockThresholdDefault,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTableTable,
      AppSettingsTableData,
      $$AppSettingsTableTableFilterComposer,
      $$AppSettingsTableTableOrderingComposer,
      $$AppSettingsTableTableAnnotationComposer,
      $$AppSettingsTableTableCreateCompanionBuilder,
      $$AppSettingsTableTableUpdateCompanionBuilder,
      (
        AppSettingsTableData,
        BaseReferences<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSettingsTableData
        >,
      ),
      AppSettingsTableData,
      PrefetchHooks Function()
    >;
typedef $$BackupLogsTableCreateCompanionBuilder =
    BackupLogsCompanion Function({
      required String id,
      required String storeId,
      required String filePath,
      Value<int> sizeBytes,
      required String type,
      required String status,
      Value<String?> errorMessage,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BackupLogsTableUpdateCompanionBuilder =
    BackupLogsCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> filePath,
      Value<int> sizeBytes,
      Value<String> type,
      Value<String> status,
      Value<String?> errorMessage,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$BackupLogsTableFilterComposer
    extends Composer<_$AppDatabase, $BackupLogsTable> {
  $$BackupLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BackupLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $BackupLogsTable> {
  $$BackupLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BackupLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BackupLogsTable> {
  $$BackupLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BackupLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BackupLogsTable,
          BackupLog,
          $$BackupLogsTableFilterComposer,
          $$BackupLogsTableOrderingComposer,
          $$BackupLogsTableAnnotationComposer,
          $$BackupLogsTableCreateCompanionBuilder,
          $$BackupLogsTableUpdateCompanionBuilder,
          (
            BackupLog,
            BaseReferences<_$AppDatabase, $BackupLogsTable, BackupLog>,
          ),
          BackupLog,
          PrefetchHooks Function()
        > {
  $$BackupLogsTableTableManager(_$AppDatabase db, $BackupLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BackupLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BackupLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BackupLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BackupLogsCompanion(
                id: id,
                storeId: storeId,
                filePath: filePath,
                sizeBytes: sizeBytes,
                type: type,
                status: status,
                errorMessage: errorMessage,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String filePath,
                Value<int> sizeBytes = const Value.absent(),
                required String type,
                required String status,
                Value<String?> errorMessage = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BackupLogsCompanion.insert(
                id: id,
                storeId: storeId,
                filePath: filePath,
                sizeBytes: sizeBytes,
                type: type,
                status: status,
                errorMessage: errorMessage,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BackupLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BackupLogsTable,
      BackupLog,
      $$BackupLogsTableFilterComposer,
      $$BackupLogsTableOrderingComposer,
      $$BackupLogsTableAnnotationComposer,
      $$BackupLogsTableCreateCompanionBuilder,
      $$BackupLogsTableUpdateCompanionBuilder,
      (BackupLog, BaseReferences<_$AppDatabase, $BackupLogsTable, BackupLog>),
      BackupLog,
      PrefetchHooks Function()
    >;
typedef $$AuditLogsTableCreateCompanionBuilder =
    AuditLogsCompanion Function({
      required String id,
      required String storeId,
      required String userId,
      required String action,
      required String entityType,
      Value<String?> entityId,
      Value<String?> beforeValueJson,
      Value<String?> afterValueJson,
      required DateTime timestamp,
      Value<int> rowid,
    });
typedef $$AuditLogsTableUpdateCompanionBuilder =
    AuditLogsCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> userId,
      Value<String> action,
      Value<String> entityType,
      Value<String?> entityId,
      Value<String?> beforeValueJson,
      Value<String?> afterValueJson,
      Value<DateTime> timestamp,
      Value<int> rowid,
    });

class $$AuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beforeValueJson => $composableBuilder(
    column: $table.beforeValueJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get afterValueJson => $composableBuilder(
    column: $table.afterValueJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beforeValueJson => $composableBuilder(
    column: $table.beforeValueJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get afterValueJson => $composableBuilder(
    column: $table.afterValueJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get beforeValueJson => $composableBuilder(
    column: $table.beforeValueJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get afterValueJson => $composableBuilder(
    column: $table.afterValueJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$AuditLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogsTable,
          AuditLog,
          $$AuditLogsTableFilterComposer,
          $$AuditLogsTableOrderingComposer,
          $$AuditLogsTableAnnotationComposer,
          $$AuditLogsTableCreateCompanionBuilder,
          $$AuditLogsTableUpdateCompanionBuilder,
          (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
          AuditLog,
          PrefetchHooks Function()
        > {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String?> entityId = const Value.absent(),
                Value<String?> beforeValueJson = const Value.absent(),
                Value<String?> afterValueJson = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion(
                id: id,
                storeId: storeId,
                userId: userId,
                action: action,
                entityType: entityType,
                entityId: entityId,
                beforeValueJson: beforeValueJson,
                afterValueJson: afterValueJson,
                timestamp: timestamp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String userId,
                required String action,
                required String entityType,
                Value<String?> entityId = const Value.absent(),
                Value<String?> beforeValueJson = const Value.absent(),
                Value<String?> afterValueJson = const Value.absent(),
                required DateTime timestamp,
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion.insert(
                id: id,
                storeId: storeId,
                userId: userId,
                action: action,
                entityType: entityType,
                entityId: entityId,
                beforeValueJson: beforeValueJson,
                afterValueJson: afterValueJson,
                timestamp: timestamp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogsTable,
      AuditLog,
      $$AuditLogsTableFilterComposer,
      $$AuditLogsTableOrderingComposer,
      $$AuditLogsTableAnnotationComposer,
      $$AuditLogsTableCreateCompanionBuilder,
      $$AuditLogsTableUpdateCompanionBuilder,
      (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
      AuditLog,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$StoresTableTableManager get stores =>
      $$StoresTableTableManager(_db, _db.stores);
  $$BranchesTableTableManager get branches =>
      $$BranchesTableTableManager(_db, _db.branches);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$ActivationCodesTableTableManager get activationCodes =>
      $$ActivationCodesTableTableManager(_db, _db.activationCodes);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TaxRatesTableTableManager get taxRates =>
      $$TaxRatesTableTableManager(_db, _db.taxRates);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$StockItemsTableTableManager get stockItems =>
      $$StockItemsTableTableManager(_db, _db.stockItems);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(_db, _db.stockMovements);
  $$StockTransfersTableTableManager get stockTransfers =>
      $$StockTransfersTableTableManager(_db, _db.stockTransfers);
  $$StockTransferLinesTableTableManager get stockTransferLines =>
      $$StockTransferLinesTableTableManager(_db, _db.stockTransferLines);
  $$PurchaseOrdersTableTableManager get purchaseOrders =>
      $$PurchaseOrdersTableTableManager(_db, _db.purchaseOrders);
  $$PurchaseOrderLinesTableTableManager get purchaseOrderLines =>
      $$PurchaseOrderLinesTableTableManager(_db, _db.purchaseOrderLines);
  $$DiscountsTableTableManager get discounts =>
      $$DiscountsTableTableManager(_db, _db.discounts);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$DebtLedgerEntriesTableTableManager get debtLedgerEntries =>
      $$DebtLedgerEntriesTableTableManager(_db, _db.debtLedgerEntries);
  $$DebtPaymentsTableTableManager get debtPayments =>
      $$DebtPaymentsTableTableManager(_db, _db.debtPayments);
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db, _db.suppliers);
  $$SupplierTransactionsTableTableManager get supplierTransactions =>
      $$SupplierTransactionsTableTableManager(_db, _db.supplierTransactions);
  $$ChartOfAccountsTableTableManager get chartOfAccounts =>
      $$ChartOfAccountsTableTableManager(_db, _db.chartOfAccounts);
  $$JournalEntriesTableTableManager get journalEntries =>
      $$JournalEntriesTableTableManager(_db, _db.journalEntries);
  $$JournalLinesTableTableManager get journalLines =>
      $$JournalLinesTableTableManager(_db, _db.journalLines);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
  $$SaleLinesTableTableManager get saleLines =>
      $$SaleLinesTableTableManager(_db, _db.saleLines);
  $$SaleReturnsTableTableManager get saleReturns =>
      $$SaleReturnsTableTableManager(_db, _db.saleReturns);
  $$SaleReturnLinesTableTableManager get saleReturnLines =>
      $$SaleReturnLinesTableTableManager(_db, _db.saleReturnLines);
  $$ShiftsTableTableManager get shifts =>
      $$ShiftsTableTableManager(_db, _db.shifts);
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(_db, _db.appSettingsTable);
  $$BackupLogsTableTableManager get backupLogs =>
      $$BackupLogsTableTableManager(_db, _db.backupLogs);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
}
