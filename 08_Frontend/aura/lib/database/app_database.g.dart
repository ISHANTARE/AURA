// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WorkspacesTable extends Workspaces
    with TableInfo<$WorkspacesTable, Workspace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkspacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorHexMeta =
      const VerificationMeta('colorHex');
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
      'color_hex', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#C8FF00'));
  static const VerificationMeta _iconKeyMeta =
      const VerificationMeta('iconKey');
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
      'icon_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('custom'));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('USER_EXPLICIT'));
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        colorHex,
        iconKey,
        sortOrder,
        createdBy,
        isArchived,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workspaces';
  @override
  VerificationContext validateIntegrity(Insertable<Workspace> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(_colorHexMeta,
          colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta));
    }
    if (data.containsKey('icon_key')) {
      context.handle(_iconKeyMeta,
          iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Workspace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Workspace(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      colorHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_hex'])!,
      iconKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_key'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $WorkspacesTable createAlias(String alias) {
    return $WorkspacesTable(attachedDatabase, alias);
  }
}

class Workspace extends DataClass implements Insertable<Workspace> {
  final String id;
  final String name;
  final String colorHex;
  final String iconKey;
  final int sortOrder;
  final String createdBy;
  final bool isArchived;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const Workspace(
      {required this.id,
      required this.name,
      required this.colorHex,
      required this.iconKey,
      required this.sortOrder,
      required this.createdBy,
      required this.isArchived,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color_hex'] = Variable<String>(colorHex);
    map['icon_key'] = Variable<String>(iconKey);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_by'] = Variable<String>(createdBy);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  WorkspacesCompanion toCompanion(bool nullToAbsent) {
    return WorkspacesCompanion(
      id: Value(id),
      name: Value(name),
      colorHex: Value(colorHex),
      iconKey: Value(iconKey),
      sortOrder: Value(sortOrder),
      createdBy: Value(createdBy),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Workspace.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Workspace(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'colorHex': serializer.toJson<String>(colorHex),
      'iconKey': serializer.toJson<String>(iconKey),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdBy': serializer.toJson<String>(createdBy),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  Workspace copyWith(
          {String? id,
          String? name,
          String? colorHex,
          String? iconKey,
          int? sortOrder,
          String? createdBy,
          bool? isArchived,
          int? createdAt,
          int? updatedAt,
          Value<int?> deletedAt = const Value.absent()}) =>
      Workspace(
        id: id ?? this.id,
        name: name ?? this.name,
        colorHex: colorHex ?? this.colorHex,
        iconKey: iconKey ?? this.iconKey,
        sortOrder: sortOrder ?? this.sortOrder,
        createdBy: createdBy ?? this.createdBy,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Workspace copyWithCompanion(WorkspacesCompanion data) {
    return Workspace(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Workspace(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('iconKey: $iconKey, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdBy: $createdBy, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, colorHex, iconKey, sortOrder,
      createdBy, isArchived, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Workspace &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorHex == this.colorHex &&
          other.iconKey == this.iconKey &&
          other.sortOrder == this.sortOrder &&
          other.createdBy == this.createdBy &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class WorkspacesCompanion extends UpdateCompanion<Workspace> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> colorHex;
  final Value<String> iconKey;
  final Value<int> sortOrder;
  final Value<String> createdBy;
  final Value<bool> isArchived;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const WorkspacesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkspacesCompanion.insert({
    required String id,
    required String name,
    this.colorHex = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.isArchived = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Workspace> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? colorHex,
    Expression<String>? iconKey,
    Expression<int>? sortOrder,
    Expression<String>? createdBy,
    Expression<bool>? isArchived,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorHex != null) 'color_hex': colorHex,
      if (iconKey != null) 'icon_key': iconKey,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdBy != null) 'created_by': createdBy,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkspacesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? colorHex,
      Value<String>? iconKey,
      Value<int>? sortOrder,
      Value<String>? createdBy,
      Value<bool>? isArchived,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int?>? deletedAt,
      Value<int>? rowid}) {
    return WorkspacesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      iconKey: iconKey ?? this.iconKey,
      sortOrder: sortOrder ?? this.sortOrder,
      createdBy: createdBy ?? this.createdBy,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkspacesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('iconKey: $iconKey, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdBy: $createdBy, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkspaceSectionsTable extends WorkspaceSections
    with TableInfo<$WorkspaceSectionsTable, WorkspaceSection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkspaceSectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _workspaceIdMeta =
      const VerificationMeta('workspaceId');
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
      'workspace_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES workspaces (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('USER_EXPLICIT'));
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        workspaceId,
        name,
        sortOrder,
        createdBy,
        isArchived,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workspace_sections';
  @override
  VerificationContext validateIntegrity(Insertable<WorkspaceSection> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
          _workspaceIdMeta,
          workspaceId.isAcceptableOrUnknown(
              data['workspace_id']!, _workspaceIdMeta));
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkspaceSection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkspaceSection(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      workspaceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}workspace_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $WorkspaceSectionsTable createAlias(String alias) {
    return $WorkspaceSectionsTable(attachedDatabase, alias);
  }
}

class WorkspaceSection extends DataClass
    implements Insertable<WorkspaceSection> {
  final String id;
  final String workspaceId;
  final String name;
  final int sortOrder;
  final String createdBy;
  final bool isArchived;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const WorkspaceSection(
      {required this.id,
      required this.workspaceId,
      required this.name,
      required this.sortOrder,
      required this.createdBy,
      required this.isArchived,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_by'] = Variable<String>(createdBy);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  WorkspaceSectionsCompanion toCompanion(bool nullToAbsent) {
    return WorkspaceSectionsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      name: Value(name),
      sortOrder: Value(sortOrder),
      createdBy: Value(createdBy),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory WorkspaceSection.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkspaceSection(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdBy': serializer.toJson<String>(createdBy),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  WorkspaceSection copyWith(
          {String? id,
          String? workspaceId,
          String? name,
          int? sortOrder,
          String? createdBy,
          bool? isArchived,
          int? createdAt,
          int? updatedAt,
          Value<int?> deletedAt = const Value.absent()}) =>
      WorkspaceSection(
        id: id ?? this.id,
        workspaceId: workspaceId ?? this.workspaceId,
        name: name ?? this.name,
        sortOrder: sortOrder ?? this.sortOrder,
        createdBy: createdBy ?? this.createdBy,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  WorkspaceSection copyWithCompanion(WorkspaceSectionsCompanion data) {
    return WorkspaceSection(
      id: data.id.present ? data.id.value : this.id,
      workspaceId:
          data.workspaceId.present ? data.workspaceId.value : this.workspaceId,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkspaceSection(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdBy: $createdBy, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, workspaceId, name, sortOrder, createdBy,
      isArchived, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkspaceSection &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.createdBy == this.createdBy &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class WorkspaceSectionsCompanion extends UpdateCompanion<WorkspaceSection> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<String> createdBy;
  final Value<bool> isArchived;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const WorkspaceSectionsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkspaceSectionsCompanion.insert({
    required String id,
    required String workspaceId,
    required String name,
    this.sortOrder = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.isArchived = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        workspaceId = Value(workspaceId),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<WorkspaceSection> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<String>? createdBy,
    Expression<bool>? isArchived,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdBy != null) 'created_by': createdBy,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkspaceSectionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? workspaceId,
      Value<String>? name,
      Value<int>? sortOrder,
      Value<String>? createdBy,
      Value<bool>? isArchived,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int?>? deletedAt,
      Value<int>? rowid}) {
    return WorkspaceSectionsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      createdBy: createdBy ?? this.createdBy,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkspaceSectionsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdBy: $createdBy, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _workspaceIdMeta =
      const VerificationMeta('workspaceId');
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
      'workspace_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES workspaces (id)'));
  static const VerificationMeta _sectionIdMeta =
      const VerificationMeta('sectionId');
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
      'section_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES workspace_sections (id)'));
  static const VerificationMeta _parentTaskIdMeta =
      const VerificationMeta('parentTaskId');
  @override
  late final GeneratedColumn<String> parentTaskId = GeneratedColumn<String>(
      'parent_task_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deadlineMeta =
      const VerificationMeta('deadline');
  @override
  late final GeneratedColumn<int> deadline = GeneratedColumn<int>(
      'deadline', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _estimatedHoursMeta =
      const VerificationMeta('estimatedHours');
  @override
  late final GeneratedColumn<double> estimatedHours = GeneratedColumn<double>(
      'estimated_hours', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('medium'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('todo'));
  static const VerificationMeta _isRecurringMeta =
      const VerificationMeta('isRecurring');
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
      'is_recurring', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_recurring" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _recurrenceTypeMeta =
      const VerificationMeta('recurrenceType');
  @override
  late final GeneratedColumn<String> recurrenceType = GeneratedColumn<String>(
      'recurrence_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recurrenceDaysMeta =
      const VerificationMeta('recurrenceDays');
  @override
  late final GeneratedColumn<String> recurrenceDays = GeneratedColumn<String>(
      'recurrence_days', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recurrenceStartMeta =
      const VerificationMeta('recurrenceStart');
  @override
  late final GeneratedColumn<int> recurrenceStart = GeneratedColumn<int>(
      'recurrence_start', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _recurrenceEndMeta =
      const VerificationMeta('recurrenceEnd');
  @override
  late final GeneratedColumn<int> recurrenceEnd = GeneratedColumn<int>(
      'recurrence_end', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _contactMeta =
      const VerificationMeta('contact');
  @override
  late final GeneratedColumn<String> contact = GeneratedColumn<String>(
      'contact', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _voiceNotePathMeta =
      const VerificationMeta('voiceNotePath');
  @override
  late final GeneratedColumn<String> voiceNotePath = GeneratedColumn<String>(
      'voice_note_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('text'));
  static const VerificationMeta _aiRawTranscriptMeta =
      const VerificationMeta('aiRawTranscript');
  @override
  late final GeneratedColumn<String> aiRawTranscript = GeneratedColumn<String>(
      'ai_raw_transcript', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _aiGeneratedMeta =
      const VerificationMeta('aiGenerated');
  @override
  late final GeneratedColumn<bool> aiGenerated = GeneratedColumn<bool>(
      'ai_generated', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("ai_generated" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        workspaceId,
        sectionId,
        parentTaskId,
        name,
        description,
        deadline,
        estimatedHours,
        priority,
        status,
        isRecurring,
        recurrenceType,
        recurrenceDays,
        recurrenceStart,
        recurrenceEnd,
        contact,
        voiceNotePath,
        source,
        aiRawTranscript,
        aiGenerated,
        completedAt,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<Task> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
          _workspaceIdMeta,
          workspaceId.isAcceptableOrUnknown(
              data['workspace_id']!, _workspaceIdMeta));
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(_sectionIdMeta,
          sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta));
    }
    if (data.containsKey('parent_task_id')) {
      context.handle(
          _parentTaskIdMeta,
          parentTaskId.isAcceptableOrUnknown(
              data['parent_task_id']!, _parentTaskIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('deadline')) {
      context.handle(_deadlineMeta,
          deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta));
    }
    if (data.containsKey('estimated_hours')) {
      context.handle(
          _estimatedHoursMeta,
          estimatedHours.isAcceptableOrUnknown(
              data['estimated_hours']!, _estimatedHoursMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
          _isRecurringMeta,
          isRecurring.isAcceptableOrUnknown(
              data['is_recurring']!, _isRecurringMeta));
    }
    if (data.containsKey('recurrence_type')) {
      context.handle(
          _recurrenceTypeMeta,
          recurrenceType.isAcceptableOrUnknown(
              data['recurrence_type']!, _recurrenceTypeMeta));
    }
    if (data.containsKey('recurrence_days')) {
      context.handle(
          _recurrenceDaysMeta,
          recurrenceDays.isAcceptableOrUnknown(
              data['recurrence_days']!, _recurrenceDaysMeta));
    }
    if (data.containsKey('recurrence_start')) {
      context.handle(
          _recurrenceStartMeta,
          recurrenceStart.isAcceptableOrUnknown(
              data['recurrence_start']!, _recurrenceStartMeta));
    }
    if (data.containsKey('recurrence_end')) {
      context.handle(
          _recurrenceEndMeta,
          recurrenceEnd.isAcceptableOrUnknown(
              data['recurrence_end']!, _recurrenceEndMeta));
    }
    if (data.containsKey('contact')) {
      context.handle(_contactMeta,
          contact.isAcceptableOrUnknown(data['contact']!, _contactMeta));
    }
    if (data.containsKey('voice_note_path')) {
      context.handle(
          _voiceNotePathMeta,
          voiceNotePath.isAcceptableOrUnknown(
              data['voice_note_path']!, _voiceNotePathMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('ai_raw_transcript')) {
      context.handle(
          _aiRawTranscriptMeta,
          aiRawTranscript.isAcceptableOrUnknown(
              data['ai_raw_transcript']!, _aiRawTranscriptMeta));
    }
    if (data.containsKey('ai_generated')) {
      context.handle(
          _aiGeneratedMeta,
          aiGenerated.isAcceptableOrUnknown(
              data['ai_generated']!, _aiGeneratedMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      workspaceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}workspace_id'])!,
      sectionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}section_id']),
      parentTaskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_task_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      deadline: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deadline']),
      estimatedHours: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}estimated_hours']),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      isRecurring: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_recurring'])!,
      recurrenceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recurrence_type']),
      recurrenceDays: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recurrence_days']),
      recurrenceStart: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recurrence_start']),
      recurrenceEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recurrence_end']),
      contact: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact']),
      voiceNotePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}voice_note_path']),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      aiRawTranscript: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}ai_raw_transcript']),
      aiGenerated: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}ai_generated'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}completed_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final String id;
  final String workspaceId;
  final String? sectionId;
  final String? parentTaskId;
  final String name;
  final String? description;
  final int? deadline;
  final double? estimatedHours;
  final String priority;
  final String status;
  final bool isRecurring;
  final String? recurrenceType;
  final String? recurrenceDays;
  final int? recurrenceStart;
  final int? recurrenceEnd;
  final String? contact;
  final String? voiceNotePath;
  final String source;
  final String? aiRawTranscript;
  final bool aiGenerated;
  final int? completedAt;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const Task(
      {required this.id,
      required this.workspaceId,
      this.sectionId,
      this.parentTaskId,
      required this.name,
      this.description,
      this.deadline,
      this.estimatedHours,
      required this.priority,
      required this.status,
      required this.isRecurring,
      this.recurrenceType,
      this.recurrenceDays,
      this.recurrenceStart,
      this.recurrenceEnd,
      this.contact,
      this.voiceNotePath,
      required this.source,
      this.aiRawTranscript,
      required this.aiGenerated,
      this.completedAt,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || sectionId != null) {
      map['section_id'] = Variable<String>(sectionId);
    }
    if (!nullToAbsent || parentTaskId != null) {
      map['parent_task_id'] = Variable<String>(parentTaskId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<int>(deadline);
    }
    if (!nullToAbsent || estimatedHours != null) {
      map['estimated_hours'] = Variable<double>(estimatedHours);
    }
    map['priority'] = Variable<String>(priority);
    map['status'] = Variable<String>(status);
    map['is_recurring'] = Variable<bool>(isRecurring);
    if (!nullToAbsent || recurrenceType != null) {
      map['recurrence_type'] = Variable<String>(recurrenceType);
    }
    if (!nullToAbsent || recurrenceDays != null) {
      map['recurrence_days'] = Variable<String>(recurrenceDays);
    }
    if (!nullToAbsent || recurrenceStart != null) {
      map['recurrence_start'] = Variable<int>(recurrenceStart);
    }
    if (!nullToAbsent || recurrenceEnd != null) {
      map['recurrence_end'] = Variable<int>(recurrenceEnd);
    }
    if (!nullToAbsent || contact != null) {
      map['contact'] = Variable<String>(contact);
    }
    if (!nullToAbsent || voiceNotePath != null) {
      map['voice_note_path'] = Variable<String>(voiceNotePath);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || aiRawTranscript != null) {
      map['ai_raw_transcript'] = Variable<String>(aiRawTranscript);
    }
    map['ai_generated'] = Variable<bool>(aiGenerated);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      sectionId: sectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sectionId),
      parentTaskId: parentTaskId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentTaskId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      estimatedHours: estimatedHours == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedHours),
      priority: Value(priority),
      status: Value(status),
      isRecurring: Value(isRecurring),
      recurrenceType: recurrenceType == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceType),
      recurrenceDays: recurrenceDays == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceDays),
      recurrenceStart: recurrenceStart == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceStart),
      recurrenceEnd: recurrenceEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceEnd),
      contact: contact == null && nullToAbsent
          ? const Value.absent()
          : Value(contact),
      voiceNotePath: voiceNotePath == null && nullToAbsent
          ? const Value.absent()
          : Value(voiceNotePath),
      source: Value(source),
      aiRawTranscript: aiRawTranscript == null && nullToAbsent
          ? const Value.absent()
          : Value(aiRawTranscript),
      aiGenerated: Value(aiGenerated),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      sectionId: serializer.fromJson<String?>(json['sectionId']),
      parentTaskId: serializer.fromJson<String?>(json['parentTaskId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      deadline: serializer.fromJson<int?>(json['deadline']),
      estimatedHours: serializer.fromJson<double?>(json['estimatedHours']),
      priority: serializer.fromJson<String>(json['priority']),
      status: serializer.fromJson<String>(json['status']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      recurrenceType: serializer.fromJson<String?>(json['recurrenceType']),
      recurrenceDays: serializer.fromJson<String?>(json['recurrenceDays']),
      recurrenceStart: serializer.fromJson<int?>(json['recurrenceStart']),
      recurrenceEnd: serializer.fromJson<int?>(json['recurrenceEnd']),
      contact: serializer.fromJson<String?>(json['contact']),
      voiceNotePath: serializer.fromJson<String?>(json['voiceNotePath']),
      source: serializer.fromJson<String>(json['source']),
      aiRawTranscript: serializer.fromJson<String?>(json['aiRawTranscript']),
      aiGenerated: serializer.fromJson<bool>(json['aiGenerated']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'sectionId': serializer.toJson<String?>(sectionId),
      'parentTaskId': serializer.toJson<String?>(parentTaskId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'deadline': serializer.toJson<int?>(deadline),
      'estimatedHours': serializer.toJson<double?>(estimatedHours),
      'priority': serializer.toJson<String>(priority),
      'status': serializer.toJson<String>(status),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'recurrenceType': serializer.toJson<String?>(recurrenceType),
      'recurrenceDays': serializer.toJson<String?>(recurrenceDays),
      'recurrenceStart': serializer.toJson<int?>(recurrenceStart),
      'recurrenceEnd': serializer.toJson<int?>(recurrenceEnd),
      'contact': serializer.toJson<String?>(contact),
      'voiceNotePath': serializer.toJson<String?>(voiceNotePath),
      'source': serializer.toJson<String>(source),
      'aiRawTranscript': serializer.toJson<String?>(aiRawTranscript),
      'aiGenerated': serializer.toJson<bool>(aiGenerated),
      'completedAt': serializer.toJson<int?>(completedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  Task copyWith(
          {String? id,
          String? workspaceId,
          Value<String?> sectionId = const Value.absent(),
          Value<String?> parentTaskId = const Value.absent(),
          String? name,
          Value<String?> description = const Value.absent(),
          Value<int?> deadline = const Value.absent(),
          Value<double?> estimatedHours = const Value.absent(),
          String? priority,
          String? status,
          bool? isRecurring,
          Value<String?> recurrenceType = const Value.absent(),
          Value<String?> recurrenceDays = const Value.absent(),
          Value<int?> recurrenceStart = const Value.absent(),
          Value<int?> recurrenceEnd = const Value.absent(),
          Value<String?> contact = const Value.absent(),
          Value<String?> voiceNotePath = const Value.absent(),
          String? source,
          Value<String?> aiRawTranscript = const Value.absent(),
          bool? aiGenerated,
          Value<int?> completedAt = const Value.absent(),
          int? createdAt,
          int? updatedAt,
          Value<int?> deletedAt = const Value.absent()}) =>
      Task(
        id: id ?? this.id,
        workspaceId: workspaceId ?? this.workspaceId,
        sectionId: sectionId.present ? sectionId.value : this.sectionId,
        parentTaskId:
            parentTaskId.present ? parentTaskId.value : this.parentTaskId,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        deadline: deadline.present ? deadline.value : this.deadline,
        estimatedHours:
            estimatedHours.present ? estimatedHours.value : this.estimatedHours,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        isRecurring: isRecurring ?? this.isRecurring,
        recurrenceType:
            recurrenceType.present ? recurrenceType.value : this.recurrenceType,
        recurrenceDays:
            recurrenceDays.present ? recurrenceDays.value : this.recurrenceDays,
        recurrenceStart: recurrenceStart.present
            ? recurrenceStart.value
            : this.recurrenceStart,
        recurrenceEnd:
            recurrenceEnd.present ? recurrenceEnd.value : this.recurrenceEnd,
        contact: contact.present ? contact.value : this.contact,
        voiceNotePath:
            voiceNotePath.present ? voiceNotePath.value : this.voiceNotePath,
        source: source ?? this.source,
        aiRawTranscript: aiRawTranscript.present
            ? aiRawTranscript.value
            : this.aiRawTranscript,
        aiGenerated: aiGenerated ?? this.aiGenerated,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      workspaceId:
          data.workspaceId.present ? data.workspaceId.value : this.workspaceId,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      parentTaskId: data.parentTaskId.present
          ? data.parentTaskId.value
          : this.parentTaskId,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      estimatedHours: data.estimatedHours.present
          ? data.estimatedHours.value
          : this.estimatedHours,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      isRecurring:
          data.isRecurring.present ? data.isRecurring.value : this.isRecurring,
      recurrenceType: data.recurrenceType.present
          ? data.recurrenceType.value
          : this.recurrenceType,
      recurrenceDays: data.recurrenceDays.present
          ? data.recurrenceDays.value
          : this.recurrenceDays,
      recurrenceStart: data.recurrenceStart.present
          ? data.recurrenceStart.value
          : this.recurrenceStart,
      recurrenceEnd: data.recurrenceEnd.present
          ? data.recurrenceEnd.value
          : this.recurrenceEnd,
      contact: data.contact.present ? data.contact.value : this.contact,
      voiceNotePath: data.voiceNotePath.present
          ? data.voiceNotePath.value
          : this.voiceNotePath,
      source: data.source.present ? data.source.value : this.source,
      aiRawTranscript: data.aiRawTranscript.present
          ? data.aiRawTranscript.value
          : this.aiRawTranscript,
      aiGenerated:
          data.aiGenerated.present ? data.aiGenerated.value : this.aiGenerated,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('sectionId: $sectionId, ')
          ..write('parentTaskId: $parentTaskId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('deadline: $deadline, ')
          ..write('estimatedHours: $estimatedHours, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurrenceType: $recurrenceType, ')
          ..write('recurrenceDays: $recurrenceDays, ')
          ..write('recurrenceStart: $recurrenceStart, ')
          ..write('recurrenceEnd: $recurrenceEnd, ')
          ..write('contact: $contact, ')
          ..write('voiceNotePath: $voiceNotePath, ')
          ..write('source: $source, ')
          ..write('aiRawTranscript: $aiRawTranscript, ')
          ..write('aiGenerated: $aiGenerated, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        workspaceId,
        sectionId,
        parentTaskId,
        name,
        description,
        deadline,
        estimatedHours,
        priority,
        status,
        isRecurring,
        recurrenceType,
        recurrenceDays,
        recurrenceStart,
        recurrenceEnd,
        contact,
        voiceNotePath,
        source,
        aiRawTranscript,
        aiGenerated,
        completedAt,
        createdAt,
        updatedAt,
        deletedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.sectionId == this.sectionId &&
          other.parentTaskId == this.parentTaskId &&
          other.name == this.name &&
          other.description == this.description &&
          other.deadline == this.deadline &&
          other.estimatedHours == this.estimatedHours &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.isRecurring == this.isRecurring &&
          other.recurrenceType == this.recurrenceType &&
          other.recurrenceDays == this.recurrenceDays &&
          other.recurrenceStart == this.recurrenceStart &&
          other.recurrenceEnd == this.recurrenceEnd &&
          other.contact == this.contact &&
          other.voiceNotePath == this.voiceNotePath &&
          other.source == this.source &&
          other.aiRawTranscript == this.aiRawTranscript &&
          other.aiGenerated == this.aiGenerated &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> sectionId;
  final Value<String?> parentTaskId;
  final Value<String> name;
  final Value<String?> description;
  final Value<int?> deadline;
  final Value<double?> estimatedHours;
  final Value<String> priority;
  final Value<String> status;
  final Value<bool> isRecurring;
  final Value<String?> recurrenceType;
  final Value<String?> recurrenceDays;
  final Value<int?> recurrenceStart;
  final Value<int?> recurrenceEnd;
  final Value<String?> contact;
  final Value<String?> voiceNotePath;
  final Value<String> source;
  final Value<String?> aiRawTranscript;
  final Value<bool> aiGenerated;
  final Value<int?> completedAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.parentTaskId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.deadline = const Value.absent(),
    this.estimatedHours = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurrenceType = const Value.absent(),
    this.recurrenceDays = const Value.absent(),
    this.recurrenceStart = const Value.absent(),
    this.recurrenceEnd = const Value.absent(),
    this.contact = const Value.absent(),
    this.voiceNotePath = const Value.absent(),
    this.source = const Value.absent(),
    this.aiRawTranscript = const Value.absent(),
    this.aiGenerated = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String workspaceId,
    this.sectionId = const Value.absent(),
    this.parentTaskId = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.deadline = const Value.absent(),
    this.estimatedHours = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurrenceType = const Value.absent(),
    this.recurrenceDays = const Value.absent(),
    this.recurrenceStart = const Value.absent(),
    this.recurrenceEnd = const Value.absent(),
    this.contact = const Value.absent(),
    this.voiceNotePath = const Value.absent(),
    this.source = const Value.absent(),
    this.aiRawTranscript = const Value.absent(),
    this.aiGenerated = const Value.absent(),
    this.completedAt = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        workspaceId = Value(workspaceId),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? sectionId,
    Expression<String>? parentTaskId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? deadline,
    Expression<double>? estimatedHours,
    Expression<String>? priority,
    Expression<String>? status,
    Expression<bool>? isRecurring,
    Expression<String>? recurrenceType,
    Expression<String>? recurrenceDays,
    Expression<int>? recurrenceStart,
    Expression<int>? recurrenceEnd,
    Expression<String>? contact,
    Expression<String>? voiceNotePath,
    Expression<String>? source,
    Expression<String>? aiRawTranscript,
    Expression<bool>? aiGenerated,
    Expression<int>? completedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (sectionId != null) 'section_id': sectionId,
      if (parentTaskId != null) 'parent_task_id': parentTaskId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (deadline != null) 'deadline': deadline,
      if (estimatedHours != null) 'estimated_hours': estimatedHours,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (recurrenceType != null) 'recurrence_type': recurrenceType,
      if (recurrenceDays != null) 'recurrence_days': recurrenceDays,
      if (recurrenceStart != null) 'recurrence_start': recurrenceStart,
      if (recurrenceEnd != null) 'recurrence_end': recurrenceEnd,
      if (contact != null) 'contact': contact,
      if (voiceNotePath != null) 'voice_note_path': voiceNotePath,
      if (source != null) 'source': source,
      if (aiRawTranscript != null) 'ai_raw_transcript': aiRawTranscript,
      if (aiGenerated != null) 'ai_generated': aiGenerated,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? workspaceId,
      Value<String?>? sectionId,
      Value<String?>? parentTaskId,
      Value<String>? name,
      Value<String?>? description,
      Value<int?>? deadline,
      Value<double?>? estimatedHours,
      Value<String>? priority,
      Value<String>? status,
      Value<bool>? isRecurring,
      Value<String?>? recurrenceType,
      Value<String?>? recurrenceDays,
      Value<int?>? recurrenceStart,
      Value<int?>? recurrenceEnd,
      Value<String?>? contact,
      Value<String?>? voiceNotePath,
      Value<String>? source,
      Value<String?>? aiRawTranscript,
      Value<bool>? aiGenerated,
      Value<int?>? completedAt,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int?>? deletedAt,
      Value<int>? rowid}) {
    return TasksCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      sectionId: sectionId ?? this.sectionId,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      name: name ?? this.name,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceDays: recurrenceDays ?? this.recurrenceDays,
      recurrenceStart: recurrenceStart ?? this.recurrenceStart,
      recurrenceEnd: recurrenceEnd ?? this.recurrenceEnd,
      contact: contact ?? this.contact,
      voiceNotePath: voiceNotePath ?? this.voiceNotePath,
      source: source ?? this.source,
      aiRawTranscript: aiRawTranscript ?? this.aiRawTranscript,
      aiGenerated: aiGenerated ?? this.aiGenerated,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (parentTaskId.present) {
      map['parent_task_id'] = Variable<String>(parentTaskId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<int>(deadline.value);
    }
    if (estimatedHours.present) {
      map['estimated_hours'] = Variable<double>(estimatedHours.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (recurrenceType.present) {
      map['recurrence_type'] = Variable<String>(recurrenceType.value);
    }
    if (recurrenceDays.present) {
      map['recurrence_days'] = Variable<String>(recurrenceDays.value);
    }
    if (recurrenceStart.present) {
      map['recurrence_start'] = Variable<int>(recurrenceStart.value);
    }
    if (recurrenceEnd.present) {
      map['recurrence_end'] = Variable<int>(recurrenceEnd.value);
    }
    if (contact.present) {
      map['contact'] = Variable<String>(contact.value);
    }
    if (voiceNotePath.present) {
      map['voice_note_path'] = Variable<String>(voiceNotePath.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (aiRawTranscript.present) {
      map['ai_raw_transcript'] = Variable<String>(aiRawTranscript.value);
    }
    if (aiGenerated.present) {
      map['ai_generated'] = Variable<bool>(aiGenerated.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('sectionId: $sectionId, ')
          ..write('parentTaskId: $parentTaskId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('deadline: $deadline, ')
          ..write('estimatedHours: $estimatedHours, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurrenceType: $recurrenceType, ')
          ..write('recurrenceDays: $recurrenceDays, ')
          ..write('recurrenceStart: $recurrenceStart, ')
          ..write('recurrenceEnd: $recurrenceEnd, ')
          ..write('contact: $contact, ')
          ..write('voiceNotePath: $voiceNotePath, ')
          ..write('source: $source, ')
          ..write('aiRawTranscript: $aiRawTranscript, ')
          ..write('aiGenerated: $aiGenerated, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, Event> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _workspaceIdMeta =
      const VerificationMeta('workspaceId');
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
      'workspace_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES workspaces (id)'));
  static const VerificationMeta _sectionIdMeta =
      const VerificationMeta('sectionId');
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
      'section_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES workspace_sections (id)'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startAtMeta =
      const VerificationMeta('startAt');
  @override
  late final GeneratedColumn<int> startAt = GeneratedColumn<int>(
      'start_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<int> endAt = GeneratedColumn<int>(
      'end_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isRecurringMeta =
      const VerificationMeta('isRecurring');
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
      'is_recurring', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_recurring" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _recurrenceRuleMeta =
      const VerificationMeta('recurrenceRule');
  @override
  late final GeneratedColumn<String> recurrenceRule = GeneratedColumn<String>(
      'recurrence_rule', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('medium'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('upcoming'));
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('voice'));
  static const VerificationMeta _aiRawTranscriptMeta =
      const VerificationMeta('aiRawTranscript');
  @override
  late final GeneratedColumn<String> aiRawTranscript = GeneratedColumn<String>(
      'ai_raw_transcript', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _externalCalIdMeta =
      const VerificationMeta('externalCalId');
  @override
  late final GeneratedColumn<String> externalCalId = GeneratedColumn<String>(
      'external_cal_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        workspaceId,
        sectionId,
        title,
        description,
        startAt,
        endAt,
        location,
        isRecurring,
        recurrenceRule,
        priority,
        status,
        source,
        aiRawTranscript,
        externalCalId,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(Insertable<Event> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
          _workspaceIdMeta,
          workspaceId.isAcceptableOrUnknown(
              data['workspace_id']!, _workspaceIdMeta));
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(_sectionIdMeta,
          sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('start_at')) {
      context.handle(_startAtMeta,
          startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta));
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(
          _endAtMeta, endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta));
    } else if (isInserting) {
      context.missing(_endAtMeta);
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
          _isRecurringMeta,
          isRecurring.isAcceptableOrUnknown(
              data['is_recurring']!, _isRecurringMeta));
    }
    if (data.containsKey('recurrence_rule')) {
      context.handle(
          _recurrenceRuleMeta,
          recurrenceRule.isAcceptableOrUnknown(
              data['recurrence_rule']!, _recurrenceRuleMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('ai_raw_transcript')) {
      context.handle(
          _aiRawTranscriptMeta,
          aiRawTranscript.isAcceptableOrUnknown(
              data['ai_raw_transcript']!, _aiRawTranscriptMeta));
    }
    if (data.containsKey('external_cal_id')) {
      context.handle(
          _externalCalIdMeta,
          externalCalId.isAcceptableOrUnknown(
              data['external_cal_id']!, _externalCalIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Event map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Event(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      workspaceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}workspace_id'])!,
      sectionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}section_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      startAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_at'])!,
      endAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_at'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      isRecurring: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_recurring'])!,
      recurrenceRule: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recurrence_rule']),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      aiRawTranscript: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}ai_raw_transcript']),
      externalCalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}external_cal_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class Event extends DataClass implements Insertable<Event> {
  final String id;
  final String workspaceId;
  final String? sectionId;
  final String title;
  final String? description;
  final int startAt;
  final int endAt;
  final String? location;
  final bool isRecurring;
  final String? recurrenceRule;
  final String priority;
  final String status;
  final String source;
  final String? aiRawTranscript;
  final String? externalCalId;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const Event(
      {required this.id,
      required this.workspaceId,
      this.sectionId,
      required this.title,
      this.description,
      required this.startAt,
      required this.endAt,
      this.location,
      required this.isRecurring,
      this.recurrenceRule,
      required this.priority,
      required this.status,
      required this.source,
      this.aiRawTranscript,
      this.externalCalId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || sectionId != null) {
      map['section_id'] = Variable<String>(sectionId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['start_at'] = Variable<int>(startAt);
    map['end_at'] = Variable<int>(endAt);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['is_recurring'] = Variable<bool>(isRecurring);
    if (!nullToAbsent || recurrenceRule != null) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule);
    }
    map['priority'] = Variable<String>(priority);
    map['status'] = Variable<String>(status);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || aiRawTranscript != null) {
      map['ai_raw_transcript'] = Variable<String>(aiRawTranscript);
    }
    if (!nullToAbsent || externalCalId != null) {
      map['external_cal_id'] = Variable<String>(externalCalId);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      sectionId: sectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sectionId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      startAt: Value(startAt),
      endAt: Value(endAt),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      isRecurring: Value(isRecurring),
      recurrenceRule: recurrenceRule == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRule),
      priority: Value(priority),
      status: Value(status),
      source: Value(source),
      aiRawTranscript: aiRawTranscript == null && nullToAbsent
          ? const Value.absent()
          : Value(aiRawTranscript),
      externalCalId: externalCalId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalCalId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Event.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Event(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      sectionId: serializer.fromJson<String?>(json['sectionId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      startAt: serializer.fromJson<int>(json['startAt']),
      endAt: serializer.fromJson<int>(json['endAt']),
      location: serializer.fromJson<String?>(json['location']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      recurrenceRule: serializer.fromJson<String?>(json['recurrenceRule']),
      priority: serializer.fromJson<String>(json['priority']),
      status: serializer.fromJson<String>(json['status']),
      source: serializer.fromJson<String>(json['source']),
      aiRawTranscript: serializer.fromJson<String?>(json['aiRawTranscript']),
      externalCalId: serializer.fromJson<String?>(json['externalCalId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'sectionId': serializer.toJson<String?>(sectionId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'startAt': serializer.toJson<int>(startAt),
      'endAt': serializer.toJson<int>(endAt),
      'location': serializer.toJson<String?>(location),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'recurrenceRule': serializer.toJson<String?>(recurrenceRule),
      'priority': serializer.toJson<String>(priority),
      'status': serializer.toJson<String>(status),
      'source': serializer.toJson<String>(source),
      'aiRawTranscript': serializer.toJson<String?>(aiRawTranscript),
      'externalCalId': serializer.toJson<String?>(externalCalId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  Event copyWith(
          {String? id,
          String? workspaceId,
          Value<String?> sectionId = const Value.absent(),
          String? title,
          Value<String?> description = const Value.absent(),
          int? startAt,
          int? endAt,
          Value<String?> location = const Value.absent(),
          bool? isRecurring,
          Value<String?> recurrenceRule = const Value.absent(),
          String? priority,
          String? status,
          String? source,
          Value<String?> aiRawTranscript = const Value.absent(),
          Value<String?> externalCalId = const Value.absent(),
          int? createdAt,
          int? updatedAt,
          Value<int?> deletedAt = const Value.absent()}) =>
      Event(
        id: id ?? this.id,
        workspaceId: workspaceId ?? this.workspaceId,
        sectionId: sectionId.present ? sectionId.value : this.sectionId,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        startAt: startAt ?? this.startAt,
        endAt: endAt ?? this.endAt,
        location: location.present ? location.value : this.location,
        isRecurring: isRecurring ?? this.isRecurring,
        recurrenceRule:
            recurrenceRule.present ? recurrenceRule.value : this.recurrenceRule,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        source: source ?? this.source,
        aiRawTranscript: aiRawTranscript.present
            ? aiRawTranscript.value
            : this.aiRawTranscript,
        externalCalId:
            externalCalId.present ? externalCalId.value : this.externalCalId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Event copyWithCompanion(EventsCompanion data) {
    return Event(
      id: data.id.present ? data.id.value : this.id,
      workspaceId:
          data.workspaceId.present ? data.workspaceId.value : this.workspaceId,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      location: data.location.present ? data.location.value : this.location,
      isRecurring:
          data.isRecurring.present ? data.isRecurring.value : this.isRecurring,
      recurrenceRule: data.recurrenceRule.present
          ? data.recurrenceRule.value
          : this.recurrenceRule,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      source: data.source.present ? data.source.value : this.source,
      aiRawTranscript: data.aiRawTranscript.present
          ? data.aiRawTranscript.value
          : this.aiRawTranscript,
      externalCalId: data.externalCalId.present
          ? data.externalCalId.value
          : this.externalCalId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Event(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('sectionId: $sectionId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('location: $location, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('source: $source, ')
          ..write('aiRawTranscript: $aiRawTranscript, ')
          ..write('externalCalId: $externalCalId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      workspaceId,
      sectionId,
      title,
      description,
      startAt,
      endAt,
      location,
      isRecurring,
      recurrenceRule,
      priority,
      status,
      source,
      aiRawTranscript,
      externalCalId,
      createdAt,
      updatedAt,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Event &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.sectionId == this.sectionId &&
          other.title == this.title &&
          other.description == this.description &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.location == this.location &&
          other.isRecurring == this.isRecurring &&
          other.recurrenceRule == this.recurrenceRule &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.source == this.source &&
          other.aiRawTranscript == this.aiRawTranscript &&
          other.externalCalId == this.externalCalId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class EventsCompanion extends UpdateCompanion<Event> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> sectionId;
  final Value<String> title;
  final Value<String?> description;
  final Value<int> startAt;
  final Value<int> endAt;
  final Value<String?> location;
  final Value<bool> isRecurring;
  final Value<String?> recurrenceRule;
  final Value<String> priority;
  final Value<String> status;
  final Value<String> source;
  final Value<String?> aiRawTranscript;
  final Value<String?> externalCalId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.location = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.source = const Value.absent(),
    this.aiRawTranscript = const Value.absent(),
    this.externalCalId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required String id,
    required String workspaceId,
    this.sectionId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required int startAt,
    required int endAt,
    this.location = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.source = const Value.absent(),
    this.aiRawTranscript = const Value.absent(),
    this.externalCalId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        workspaceId = Value(workspaceId),
        title = Value(title),
        startAt = Value(startAt),
        endAt = Value(endAt),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Event> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? sectionId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? startAt,
    Expression<int>? endAt,
    Expression<String>? location,
    Expression<bool>? isRecurring,
    Expression<String>? recurrenceRule,
    Expression<String>? priority,
    Expression<String>? status,
    Expression<String>? source,
    Expression<String>? aiRawTranscript,
    Expression<String>? externalCalId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (sectionId != null) 'section_id': sectionId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (location != null) 'location': location,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (source != null) 'source': source,
      if (aiRawTranscript != null) 'ai_raw_transcript': aiRawTranscript,
      if (externalCalId != null) 'external_cal_id': externalCalId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? workspaceId,
      Value<String?>? sectionId,
      Value<String>? title,
      Value<String?>? description,
      Value<int>? startAt,
      Value<int>? endAt,
      Value<String?>? location,
      Value<bool>? isRecurring,
      Value<String?>? recurrenceRule,
      Value<String>? priority,
      Value<String>? status,
      Value<String>? source,
      Value<String?>? aiRawTranscript,
      Value<String?>? externalCalId,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int?>? deletedAt,
      Value<int>? rowid}) {
    return EventsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      sectionId: sectionId ?? this.sectionId,
      title: title ?? this.title,
      description: description ?? this.description,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      location: location ?? this.location,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      source: source ?? this.source,
      aiRawTranscript: aiRawTranscript ?? this.aiRawTranscript,
      externalCalId: externalCalId ?? this.externalCalId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<int>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<int>(endAt.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (recurrenceRule.present) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (aiRawTranscript.present) {
      map['ai_raw_transcript'] = Variable<String>(aiRawTranscript.value);
    }
    if (externalCalId.present) {
      map['external_cal_id'] = Variable<String>(externalCalId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('sectionId: $sectionId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('location: $location, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('source: $source, ')
          ..write('aiRawTranscript: $aiRawTranscript, ')
          ..write('externalCalId: $externalCalId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tasks (id)'));
  static const VerificationMeta _eventIdMeta =
      const VerificationMeta('eventId');
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
      'event_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES events (id)'));
  static const VerificationMeta _fireAtMeta = const VerificationMeta('fireAt');
  @override
  late final GeneratedColumn<int> fireAt = GeneratedColumn<int>(
      'fire_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('notification'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _snoozedUntilMeta =
      const VerificationMeta('snoozedUntil');
  @override
  late final GeneratedColumn<int> snoozedUntil = GeneratedColumn<int>(
      'snoozed_until', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _hasFiredMeta =
      const VerificationMeta('hasFired');
  @override
  late final GeneratedColumn<bool> hasFired = GeneratedColumn<bool>(
      'has_fired', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("has_fired" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _missedDndMeta =
      const VerificationMeta('missedDnd');
  @override
  late final GeneratedColumn<bool> missedDnd = GeneratedColumn<bool>(
      'missed_dnd', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("missed_dnd" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _replayedAtMeta =
      const VerificationMeta('replayedAt');
  @override
  late final GeneratedColumn<int> replayedAt = GeneratedColumn<int>(
      'replayed_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        taskId,
        eventId,
        fireAt,
        type,
        status,
        snoozedUntil,
        hasFired,
        missedDnd,
        replayedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(Insertable<Reminder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    }
    if (data.containsKey('event_id')) {
      context.handle(_eventIdMeta,
          eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta));
    }
    if (data.containsKey('fire_at')) {
      context.handle(_fireAtMeta,
          fireAt.isAcceptableOrUnknown(data['fire_at']!, _fireAtMeta));
    } else if (isInserting) {
      context.missing(_fireAtMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('snoozed_until')) {
      context.handle(
          _snoozedUntilMeta,
          snoozedUntil.isAcceptableOrUnknown(
              data['snoozed_until']!, _snoozedUntilMeta));
    }
    if (data.containsKey('has_fired')) {
      context.handle(_hasFiredMeta,
          hasFired.isAcceptableOrUnknown(data['has_fired']!, _hasFiredMeta));
    }
    if (data.containsKey('missed_dnd')) {
      context.handle(_missedDndMeta,
          missedDnd.isAcceptableOrUnknown(data['missed_dnd']!, _missedDndMeta));
    }
    if (data.containsKey('replayed_at')) {
      context.handle(
          _replayedAtMeta,
          replayedAt.isAcceptableOrUnknown(
              data['replayed_at']!, _replayedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id']),
      eventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_id']),
      fireAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fire_at'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      snoozedUntil: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}snoozed_until']),
      hasFired: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}has_fired'])!,
      missedDnd: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}missed_dnd'])!,
      replayedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}replayed_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final String id;
  final String? taskId;
  final String? eventId;
  final int fireAt;
  final String type;
  final String status;
  final int? snoozedUntil;
  final bool hasFired;
  final bool missedDnd;
  final int? replayedAt;
  final int createdAt;
  final int updatedAt;
  const Reminder(
      {required this.id,
      this.taskId,
      this.eventId,
      required this.fireAt,
      required this.type,
      required this.status,
      this.snoozedUntil,
      required this.hasFired,
      required this.missedDnd,
      this.replayedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<String>(taskId);
    }
    if (!nullToAbsent || eventId != null) {
      map['event_id'] = Variable<String>(eventId);
    }
    map['fire_at'] = Variable<int>(fireAt);
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || snoozedUntil != null) {
      map['snoozed_until'] = Variable<int>(snoozedUntil);
    }
    map['has_fired'] = Variable<bool>(hasFired);
    map['missed_dnd'] = Variable<bool>(missedDnd);
    if (!nullToAbsent || replayedAt != null) {
      map['replayed_at'] = Variable<int>(replayedAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      taskId:
          taskId == null && nullToAbsent ? const Value.absent() : Value(taskId),
      eventId: eventId == null && nullToAbsent
          ? const Value.absent()
          : Value(eventId),
      fireAt: Value(fireAt),
      type: Value(type),
      status: Value(status),
      snoozedUntil: snoozedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozedUntil),
      hasFired: Value(hasFired),
      missedDnd: Value(missedDnd),
      replayedAt: replayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(replayedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Reminder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String?>(json['taskId']),
      eventId: serializer.fromJson<String?>(json['eventId']),
      fireAt: serializer.fromJson<int>(json['fireAt']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      snoozedUntil: serializer.fromJson<int?>(json['snoozedUntil']),
      hasFired: serializer.fromJson<bool>(json['hasFired']),
      missedDnd: serializer.fromJson<bool>(json['missedDnd']),
      replayedAt: serializer.fromJson<int?>(json['replayedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String?>(taskId),
      'eventId': serializer.toJson<String?>(eventId),
      'fireAt': serializer.toJson<int>(fireAt),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'snoozedUntil': serializer.toJson<int?>(snoozedUntil),
      'hasFired': serializer.toJson<bool>(hasFired),
      'missedDnd': serializer.toJson<bool>(missedDnd),
      'replayedAt': serializer.toJson<int?>(replayedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Reminder copyWith(
          {String? id,
          Value<String?> taskId = const Value.absent(),
          Value<String?> eventId = const Value.absent(),
          int? fireAt,
          String? type,
          String? status,
          Value<int?> snoozedUntil = const Value.absent(),
          bool? hasFired,
          bool? missedDnd,
          Value<int?> replayedAt = const Value.absent(),
          int? createdAt,
          int? updatedAt}) =>
      Reminder(
        id: id ?? this.id,
        taskId: taskId.present ? taskId.value : this.taskId,
        eventId: eventId.present ? eventId.value : this.eventId,
        fireAt: fireAt ?? this.fireAt,
        type: type ?? this.type,
        status: status ?? this.status,
        snoozedUntil:
            snoozedUntil.present ? snoozedUntil.value : this.snoozedUntil,
        hasFired: hasFired ?? this.hasFired,
        missedDnd: missedDnd ?? this.missedDnd,
        replayedAt: replayedAt.present ? replayedAt.value : this.replayedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      fireAt: data.fireAt.present ? data.fireAt.value : this.fireAt,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      snoozedUntil: data.snoozedUntil.present
          ? data.snoozedUntil.value
          : this.snoozedUntil,
      hasFired: data.hasFired.present ? data.hasFired.value : this.hasFired,
      missedDnd: data.missedDnd.present ? data.missedDnd.value : this.missedDnd,
      replayedAt:
          data.replayedAt.present ? data.replayedAt.value : this.replayedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('eventId: $eventId, ')
          ..write('fireAt: $fireAt, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('hasFired: $hasFired, ')
          ..write('missedDnd: $missedDnd, ')
          ..write('replayedAt: $replayedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, taskId, eventId, fireAt, type, status,
      snoozedUntil, hasFired, missedDnd, replayedAt, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.eventId == this.eventId &&
          other.fireAt == this.fireAt &&
          other.type == this.type &&
          other.status == this.status &&
          other.snoozedUntil == this.snoozedUntil &&
          other.hasFired == this.hasFired &&
          other.missedDnd == this.missedDnd &&
          other.replayedAt == this.replayedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<String> id;
  final Value<String?> taskId;
  final Value<String?> eventId;
  final Value<int> fireAt;
  final Value<String> type;
  final Value<String> status;
  final Value<int?> snoozedUntil;
  final Value<bool> hasFired;
  final Value<bool> missedDnd;
  final Value<int?> replayedAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.eventId = const Value.absent(),
    this.fireAt = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.hasFired = const Value.absent(),
    this.missedDnd = const Value.absent(),
    this.replayedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    this.taskId = const Value.absent(),
    this.eventId = const Value.absent(),
    required int fireAt,
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.hasFired = const Value.absent(),
    this.missedDnd = const Value.absent(),
    this.replayedAt = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fireAt = Value(fireAt),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Reminder> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? eventId,
    Expression<int>? fireAt,
    Expression<String>? type,
    Expression<String>? status,
    Expression<int>? snoozedUntil,
    Expression<bool>? hasFired,
    Expression<bool>? missedDnd,
    Expression<int>? replayedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (eventId != null) 'event_id': eventId,
      if (fireAt != null) 'fire_at': fireAt,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (snoozedUntil != null) 'snoozed_until': snoozedUntil,
      if (hasFired != null) 'has_fired': hasFired,
      if (missedDnd != null) 'missed_dnd': missedDnd,
      if (replayedAt != null) 'replayed_at': replayedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith(
      {Value<String>? id,
      Value<String?>? taskId,
      Value<String?>? eventId,
      Value<int>? fireAt,
      Value<String>? type,
      Value<String>? status,
      Value<int?>? snoozedUntil,
      Value<bool>? hasFired,
      Value<bool>? missedDnd,
      Value<int?>? replayedAt,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return RemindersCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      eventId: eventId ?? this.eventId,
      fireAt: fireAt ?? this.fireAt,
      type: type ?? this.type,
      status: status ?? this.status,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      hasFired: hasFired ?? this.hasFired,
      missedDnd: missedDnd ?? this.missedDnd,
      replayedAt: replayedAt ?? this.replayedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (fireAt.present) {
      map['fire_at'] = Variable<int>(fireAt.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (snoozedUntil.present) {
      map['snoozed_until'] = Variable<int>(snoozedUntil.value);
    }
    if (hasFired.present) {
      map['has_fired'] = Variable<bool>(hasFired.value);
    }
    if (missedDnd.present) {
      map['missed_dnd'] = Variable<bool>(missedDnd.value);
    }
    if (replayedAt.present) {
      map['replayed_at'] = Variable<int>(replayedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('eventId: $eventId, ')
          ..write('fireAt: $fireAt, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('hasFired: $hasFired, ')
          ..write('missedDnd: $missedDnd, ')
          ..write('replayedAt: $replayedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tasks (id)'));
  static const VerificationMeta _eventIdMeta =
      const VerificationMeta('eventId');
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
      'event_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES events (id)'));
  static const VerificationMeta _workspaceIdMeta =
      const VerificationMeta('workspaceId');
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
      'workspace_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES workspaces (id)'));
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('text'));
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        taskId,
        eventId,
        workspaceId,
        content,
        type,
        filePath,
        url,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(Insertable<Note> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    }
    if (data.containsKey('event_id')) {
      context.handle(_eventIdMeta,
          eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta));
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
          _workspaceIdMeta,
          workspaceId.isAcceptableOrUnknown(
              data['workspace_id']!, _workspaceIdMeta));
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id']),
      eventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_id']),
      workspaceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}workspace_id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path']),
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class Note extends DataClass implements Insertable<Note> {
  final String id;
  final String? taskId;
  final String? eventId;
  final String workspaceId;
  final String content;
  final String type;
  final String? filePath;
  final String? url;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const Note(
      {required this.id,
      this.taskId,
      this.eventId,
      required this.workspaceId,
      required this.content,
      required this.type,
      this.filePath,
      this.url,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<String>(taskId);
    }
    if (!nullToAbsent || eventId != null) {
      map['event_id'] = Variable<String>(eventId);
    }
    map['workspace_id'] = Variable<String>(workspaceId);
    map['content'] = Variable<String>(content);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      taskId:
          taskId == null && nullToAbsent ? const Value.absent() : Value(taskId),
      eventId: eventId == null && nullToAbsent
          ? const Value.absent()
          : Value(eventId),
      workspaceId: Value(workspaceId),
      content: Value(content),
      type: Value(type),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Note.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String?>(json['taskId']),
      eventId: serializer.fromJson<String?>(json['eventId']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      content: serializer.fromJson<String>(json['content']),
      type: serializer.fromJson<String>(json['type']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      url: serializer.fromJson<String?>(json['url']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String?>(taskId),
      'eventId': serializer.toJson<String?>(eventId),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'content': serializer.toJson<String>(content),
      'type': serializer.toJson<String>(type),
      'filePath': serializer.toJson<String?>(filePath),
      'url': serializer.toJson<String?>(url),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  Note copyWith(
          {String? id,
          Value<String?> taskId = const Value.absent(),
          Value<String?> eventId = const Value.absent(),
          String? workspaceId,
          String? content,
          String? type,
          Value<String?> filePath = const Value.absent(),
          Value<String?> url = const Value.absent(),
          int? createdAt,
          int? updatedAt,
          Value<int?> deletedAt = const Value.absent()}) =>
      Note(
        id: id ?? this.id,
        taskId: taskId.present ? taskId.value : this.taskId,
        eventId: eventId.present ? eventId.value : this.eventId,
        workspaceId: workspaceId ?? this.workspaceId,
        content: content ?? this.content,
        type: type ?? this.type,
        filePath: filePath.present ? filePath.value : this.filePath,
        url: url.present ? url.value : this.url,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      workspaceId:
          data.workspaceId.present ? data.workspaceId.value : this.workspaceId,
      content: data.content.present ? data.content.value : this.content,
      type: data.type.present ? data.type.value : this.type,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      url: data.url.present ? data.url.value : this.url,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('eventId: $eventId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('content: $content, ')
          ..write('type: $type, ')
          ..write('filePath: $filePath, ')
          ..write('url: $url, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, taskId, eventId, workspaceId, content,
      type, filePath, url, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.eventId == this.eventId &&
          other.workspaceId == this.workspaceId &&
          other.content == this.content &&
          other.type == this.type &&
          other.filePath == this.filePath &&
          other.url == this.url &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<String> id;
  final Value<String?> taskId;
  final Value<String?> eventId;
  final Value<String> workspaceId;
  final Value<String> content;
  final Value<String> type;
  final Value<String?> filePath;
  final Value<String?> url;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.eventId = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.content = const Value.absent(),
    this.type = const Value.absent(),
    this.filePath = const Value.absent(),
    this.url = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    required String id,
    this.taskId = const Value.absent(),
    this.eventId = const Value.absent(),
    required String workspaceId,
    required String content,
    this.type = const Value.absent(),
    this.filePath = const Value.absent(),
    this.url = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        workspaceId = Value(workspaceId),
        content = Value(content),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Note> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? eventId,
    Expression<String>? workspaceId,
    Expression<String>? content,
    Expression<String>? type,
    Expression<String>? filePath,
    Expression<String>? url,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (eventId != null) 'event_id': eventId,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (content != null) 'content': content,
      if (type != null) 'type': type,
      if (filePath != null) 'file_path': filePath,
      if (url != null) 'url': url,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? taskId,
      Value<String?>? eventId,
      Value<String>? workspaceId,
      Value<String>? content,
      Value<String>? type,
      Value<String?>? filePath,
      Value<String?>? url,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int?>? deletedAt,
      Value<int>? rowid}) {
    return NotesCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      eventId: eventId ?? this.eventId,
      workspaceId: workspaceId ?? this.workspaceId,
      content: content ?? this.content,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      url: url ?? this.url,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('eventId: $eventId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('content: $content, ')
          ..write('type: $type, ')
          ..write('filePath: $filePath, ')
          ..write('url: $url, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SharedContentsTable extends SharedContents
    with TableInfo<$SharedContentsTable, SharedContent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SharedContentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rawPathMeta =
      const VerificationMeta('rawPath');
  @override
  late final GeneratedColumn<String> rawPath = GeneratedColumn<String>(
      'raw_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _rawUrlMeta = const VerificationMeta('rawUrl');
  @override
  late final GeneratedColumn<String> rawUrl = GeneratedColumn<String>(
      'raw_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ocrTextMeta =
      const VerificationMeta('ocrText');
  @override
  late final GeneratedColumn<String> ocrText = GeneratedColumn<String>(
      'ocr_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _aiSummaryMeta =
      const VerificationMeta('aiSummary');
  @override
  late final GeneratedColumn<String> aiSummary = GeneratedColumn<String>(
      'ai_summary', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pageTitleMeta =
      const VerificationMeta('pageTitle');
  @override
  late final GeneratedColumn<String> pageTitle = GeneratedColumn<String>(
      'page_title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _workspaceIdMeta =
      const VerificationMeta('workspaceId');
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
      'workspace_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES workspaces (id)'));
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tasks (id)'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        rawPath,
        rawUrl,
        ocrText,
        aiSummary,
        pageTitle,
        status,
        workspaceId,
        taskId,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shared_contents';
  @override
  VerificationContext validateIntegrity(Insertable<SharedContent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('raw_path')) {
      context.handle(_rawPathMeta,
          rawPath.isAcceptableOrUnknown(data['raw_path']!, _rawPathMeta));
    }
    if (data.containsKey('raw_url')) {
      context.handle(_rawUrlMeta,
          rawUrl.isAcceptableOrUnknown(data['raw_url']!, _rawUrlMeta));
    }
    if (data.containsKey('ocr_text')) {
      context.handle(_ocrTextMeta,
          ocrText.isAcceptableOrUnknown(data['ocr_text']!, _ocrTextMeta));
    }
    if (data.containsKey('ai_summary')) {
      context.handle(_aiSummaryMeta,
          aiSummary.isAcceptableOrUnknown(data['ai_summary']!, _aiSummaryMeta));
    }
    if (data.containsKey('page_title')) {
      context.handle(_pageTitleMeta,
          pageTitle.isAcceptableOrUnknown(data['page_title']!, _pageTitleMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
          _workspaceIdMeta,
          workspaceId.isAcceptableOrUnknown(
              data['workspace_id']!, _workspaceIdMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SharedContent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SharedContent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      rawPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_path']),
      rawUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_url']),
      ocrText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ocr_text']),
      aiSummary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ai_summary']),
      pageTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}page_title']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      workspaceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}workspace_id']),
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SharedContentsTable createAlias(String alias) {
    return $SharedContentsTable(attachedDatabase, alias);
  }
}

class SharedContent extends DataClass implements Insertable<SharedContent> {
  final String id;
  final String type;
  final String? rawPath;
  final String? rawUrl;
  final String? ocrText;
  final String? aiSummary;
  final String? pageTitle;
  final String status;
  final String? workspaceId;
  final String? taskId;
  final int createdAt;
  final int updatedAt;
  const SharedContent(
      {required this.id,
      required this.type,
      this.rawPath,
      this.rawUrl,
      this.ocrText,
      this.aiSummary,
      this.pageTitle,
      required this.status,
      this.workspaceId,
      this.taskId,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || rawPath != null) {
      map['raw_path'] = Variable<String>(rawPath);
    }
    if (!nullToAbsent || rawUrl != null) {
      map['raw_url'] = Variable<String>(rawUrl);
    }
    if (!nullToAbsent || ocrText != null) {
      map['ocr_text'] = Variable<String>(ocrText);
    }
    if (!nullToAbsent || aiSummary != null) {
      map['ai_summary'] = Variable<String>(aiSummary);
    }
    if (!nullToAbsent || pageTitle != null) {
      map['page_title'] = Variable<String>(pageTitle);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || workspaceId != null) {
      map['workspace_id'] = Variable<String>(workspaceId);
    }
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<String>(taskId);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  SharedContentsCompanion toCompanion(bool nullToAbsent) {
    return SharedContentsCompanion(
      id: Value(id),
      type: Value(type),
      rawPath: rawPath == null && nullToAbsent
          ? const Value.absent()
          : Value(rawPath),
      rawUrl:
          rawUrl == null && nullToAbsent ? const Value.absent() : Value(rawUrl),
      ocrText: ocrText == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrText),
      aiSummary: aiSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(aiSummary),
      pageTitle: pageTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(pageTitle),
      status: Value(status),
      workspaceId: workspaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(workspaceId),
      taskId:
          taskId == null && nullToAbsent ? const Value.absent() : Value(taskId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SharedContent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SharedContent(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      rawPath: serializer.fromJson<String?>(json['rawPath']),
      rawUrl: serializer.fromJson<String?>(json['rawUrl']),
      ocrText: serializer.fromJson<String?>(json['ocrText']),
      aiSummary: serializer.fromJson<String?>(json['aiSummary']),
      pageTitle: serializer.fromJson<String?>(json['pageTitle']),
      status: serializer.fromJson<String>(json['status']),
      workspaceId: serializer.fromJson<String?>(json['workspaceId']),
      taskId: serializer.fromJson<String?>(json['taskId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'rawPath': serializer.toJson<String?>(rawPath),
      'rawUrl': serializer.toJson<String?>(rawUrl),
      'ocrText': serializer.toJson<String?>(ocrText),
      'aiSummary': serializer.toJson<String?>(aiSummary),
      'pageTitle': serializer.toJson<String?>(pageTitle),
      'status': serializer.toJson<String>(status),
      'workspaceId': serializer.toJson<String?>(workspaceId),
      'taskId': serializer.toJson<String?>(taskId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  SharedContent copyWith(
          {String? id,
          String? type,
          Value<String?> rawPath = const Value.absent(),
          Value<String?> rawUrl = const Value.absent(),
          Value<String?> ocrText = const Value.absent(),
          Value<String?> aiSummary = const Value.absent(),
          Value<String?> pageTitle = const Value.absent(),
          String? status,
          Value<String?> workspaceId = const Value.absent(),
          Value<String?> taskId = const Value.absent(),
          int? createdAt,
          int? updatedAt}) =>
      SharedContent(
        id: id ?? this.id,
        type: type ?? this.type,
        rawPath: rawPath.present ? rawPath.value : this.rawPath,
        rawUrl: rawUrl.present ? rawUrl.value : this.rawUrl,
        ocrText: ocrText.present ? ocrText.value : this.ocrText,
        aiSummary: aiSummary.present ? aiSummary.value : this.aiSummary,
        pageTitle: pageTitle.present ? pageTitle.value : this.pageTitle,
        status: status ?? this.status,
        workspaceId: workspaceId.present ? workspaceId.value : this.workspaceId,
        taskId: taskId.present ? taskId.value : this.taskId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SharedContent copyWithCompanion(SharedContentsCompanion data) {
    return SharedContent(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      rawPath: data.rawPath.present ? data.rawPath.value : this.rawPath,
      rawUrl: data.rawUrl.present ? data.rawUrl.value : this.rawUrl,
      ocrText: data.ocrText.present ? data.ocrText.value : this.ocrText,
      aiSummary: data.aiSummary.present ? data.aiSummary.value : this.aiSummary,
      pageTitle: data.pageTitle.present ? data.pageTitle.value : this.pageTitle,
      status: data.status.present ? data.status.value : this.status,
      workspaceId:
          data.workspaceId.present ? data.workspaceId.value : this.workspaceId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SharedContent(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('rawPath: $rawPath, ')
          ..write('rawUrl: $rawUrl, ')
          ..write('ocrText: $ocrText, ')
          ..write('aiSummary: $aiSummary, ')
          ..write('pageTitle: $pageTitle, ')
          ..write('status: $status, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('taskId: $taskId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, rawPath, rawUrl, ocrText, aiSummary,
      pageTitle, status, workspaceId, taskId, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SharedContent &&
          other.id == this.id &&
          other.type == this.type &&
          other.rawPath == this.rawPath &&
          other.rawUrl == this.rawUrl &&
          other.ocrText == this.ocrText &&
          other.aiSummary == this.aiSummary &&
          other.pageTitle == this.pageTitle &&
          other.status == this.status &&
          other.workspaceId == this.workspaceId &&
          other.taskId == this.taskId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SharedContentsCompanion extends UpdateCompanion<SharedContent> {
  final Value<String> id;
  final Value<String> type;
  final Value<String?> rawPath;
  final Value<String?> rawUrl;
  final Value<String?> ocrText;
  final Value<String?> aiSummary;
  final Value<String?> pageTitle;
  final Value<String> status;
  final Value<String?> workspaceId;
  final Value<String?> taskId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const SharedContentsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.rawPath = const Value.absent(),
    this.rawUrl = const Value.absent(),
    this.ocrText = const Value.absent(),
    this.aiSummary = const Value.absent(),
    this.pageTitle = const Value.absent(),
    this.status = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SharedContentsCompanion.insert({
    required String id,
    required String type,
    this.rawPath = const Value.absent(),
    this.rawUrl = const Value.absent(),
    this.ocrText = const Value.absent(),
    this.aiSummary = const Value.absent(),
    this.pageTitle = const Value.absent(),
    this.status = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.taskId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<SharedContent> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? rawPath,
    Expression<String>? rawUrl,
    Expression<String>? ocrText,
    Expression<String>? aiSummary,
    Expression<String>? pageTitle,
    Expression<String>? status,
    Expression<String>? workspaceId,
    Expression<String>? taskId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (rawPath != null) 'raw_path': rawPath,
      if (rawUrl != null) 'raw_url': rawUrl,
      if (ocrText != null) 'ocr_text': ocrText,
      if (aiSummary != null) 'ai_summary': aiSummary,
      if (pageTitle != null) 'page_title': pageTitle,
      if (status != null) 'status': status,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (taskId != null) 'task_id': taskId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SharedContentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String?>? rawPath,
      Value<String?>? rawUrl,
      Value<String?>? ocrText,
      Value<String?>? aiSummary,
      Value<String?>? pageTitle,
      Value<String>? status,
      Value<String?>? workspaceId,
      Value<String?>? taskId,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return SharedContentsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      rawPath: rawPath ?? this.rawPath,
      rawUrl: rawUrl ?? this.rawUrl,
      ocrText: ocrText ?? this.ocrText,
      aiSummary: aiSummary ?? this.aiSummary,
      pageTitle: pageTitle ?? this.pageTitle,
      status: status ?? this.status,
      workspaceId: workspaceId ?? this.workspaceId,
      taskId: taskId ?? this.taskId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (rawPath.present) {
      map['raw_path'] = Variable<String>(rawPath.value);
    }
    if (rawUrl.present) {
      map['raw_url'] = Variable<String>(rawUrl.value);
    }
    if (ocrText.present) {
      map['ocr_text'] = Variable<String>(ocrText.value);
    }
    if (aiSummary.present) {
      map['ai_summary'] = Variable<String>(aiSummary.value);
    }
    if (pageTitle.present) {
      map['page_title'] = Variable<String>(pageTitle.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SharedContentsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('rawPath: $rawPath, ')
          ..write('rawUrl: $rawUrl, ')
          ..write('ocrText: $ocrText, ')
          ..write('aiSummary: $aiSummary, ')
          ..write('pageTitle: $pageTitle, ')
          ..write('status: $status, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('taskId: $taskId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationLogsTable extends NotificationLogs
    with TableInfo<$NotificationLogsTable, NotificationLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reminderIdMeta =
      const VerificationMeta('reminderId');
  @override
  late final GeneratedColumn<String> reminderId = GeneratedColumn<String>(
      'reminder_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES reminders (id)'));
  static const VerificationMeta _scheduledAtMeta =
      const VerificationMeta('scheduledAt');
  @override
  late final GeneratedColumn<int> scheduledAt = GeneratedColumn<int>(
      'scheduled_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _firedAtMeta =
      const VerificationMeta('firedAt');
  @override
  late final GeneratedColumn<int> firedAt = GeneratedColumn<int>(
      'fired_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _wasDndMeta = const VerificationMeta('wasDnd');
  @override
  late final GeneratedColumn<bool> wasDnd = GeneratedColumn<bool>(
      'was_dnd', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("was_dnd" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _replayedAtMeta =
      const VerificationMeta('replayedAt');
  @override
  late final GeneratedColumn<int> replayedAt = GeneratedColumn<int>(
      'replayed_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _userDismissedMeta =
      const VerificationMeta('userDismissed');
  @override
  late final GeneratedColumn<bool> userDismissed = GeneratedColumn<bool>(
      'user_dismissed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("user_dismissed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        reminderId,
        scheduledAt,
        firedAt,
        wasDnd,
        replayedAt,
        userDismissed,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_logs';
  @override
  VerificationContext validateIntegrity(Insertable<NotificationLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('reminder_id')) {
      context.handle(
          _reminderIdMeta,
          reminderId.isAcceptableOrUnknown(
              data['reminder_id']!, _reminderIdMeta));
    } else if (isInserting) {
      context.missing(_reminderIdMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
          _scheduledAtMeta,
          scheduledAt.isAcceptableOrUnknown(
              data['scheduled_at']!, _scheduledAtMeta));
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('fired_at')) {
      context.handle(_firedAtMeta,
          firedAt.isAcceptableOrUnknown(data['fired_at']!, _firedAtMeta));
    }
    if (data.containsKey('was_dnd')) {
      context.handle(_wasDndMeta,
          wasDnd.isAcceptableOrUnknown(data['was_dnd']!, _wasDndMeta));
    }
    if (data.containsKey('replayed_at')) {
      context.handle(
          _replayedAtMeta,
          replayedAt.isAcceptableOrUnknown(
              data['replayed_at']!, _replayedAtMeta));
    }
    if (data.containsKey('user_dismissed')) {
      context.handle(
          _userDismissedMeta,
          userDismissed.isAcceptableOrUnknown(
              data['user_dismissed']!, _userDismissedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      reminderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reminder_id'])!,
      scheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}scheduled_at'])!,
      firedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fired_at']),
      wasDnd: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}was_dnd'])!,
      replayedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}replayed_at']),
      userDismissed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}user_dismissed'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $NotificationLogsTable createAlias(String alias) {
    return $NotificationLogsTable(attachedDatabase, alias);
  }
}

class NotificationLog extends DataClass implements Insertable<NotificationLog> {
  final String id;
  final String reminderId;
  final int scheduledAt;
  final int? firedAt;
  final bool wasDnd;
  final int? replayedAt;
  final bool userDismissed;
  final int createdAt;
  const NotificationLog(
      {required this.id,
      required this.reminderId,
      required this.scheduledAt,
      this.firedAt,
      required this.wasDnd,
      this.replayedAt,
      required this.userDismissed,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['reminder_id'] = Variable<String>(reminderId);
    map['scheduled_at'] = Variable<int>(scheduledAt);
    if (!nullToAbsent || firedAt != null) {
      map['fired_at'] = Variable<int>(firedAt);
    }
    map['was_dnd'] = Variable<bool>(wasDnd);
    if (!nullToAbsent || replayedAt != null) {
      map['replayed_at'] = Variable<int>(replayedAt);
    }
    map['user_dismissed'] = Variable<bool>(userDismissed);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  NotificationLogsCompanion toCompanion(bool nullToAbsent) {
    return NotificationLogsCompanion(
      id: Value(id),
      reminderId: Value(reminderId),
      scheduledAt: Value(scheduledAt),
      firedAt: firedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(firedAt),
      wasDnd: Value(wasDnd),
      replayedAt: replayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(replayedAt),
      userDismissed: Value(userDismissed),
      createdAt: Value(createdAt),
    );
  }

  factory NotificationLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationLog(
      id: serializer.fromJson<String>(json['id']),
      reminderId: serializer.fromJson<String>(json['reminderId']),
      scheduledAt: serializer.fromJson<int>(json['scheduledAt']),
      firedAt: serializer.fromJson<int?>(json['firedAt']),
      wasDnd: serializer.fromJson<bool>(json['wasDnd']),
      replayedAt: serializer.fromJson<int?>(json['replayedAt']),
      userDismissed: serializer.fromJson<bool>(json['userDismissed']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'reminderId': serializer.toJson<String>(reminderId),
      'scheduledAt': serializer.toJson<int>(scheduledAt),
      'firedAt': serializer.toJson<int?>(firedAt),
      'wasDnd': serializer.toJson<bool>(wasDnd),
      'replayedAt': serializer.toJson<int?>(replayedAt),
      'userDismissed': serializer.toJson<bool>(userDismissed),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  NotificationLog copyWith(
          {String? id,
          String? reminderId,
          int? scheduledAt,
          Value<int?> firedAt = const Value.absent(),
          bool? wasDnd,
          Value<int?> replayedAt = const Value.absent(),
          bool? userDismissed,
          int? createdAt}) =>
      NotificationLog(
        id: id ?? this.id,
        reminderId: reminderId ?? this.reminderId,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        firedAt: firedAt.present ? firedAt.value : this.firedAt,
        wasDnd: wasDnd ?? this.wasDnd,
        replayedAt: replayedAt.present ? replayedAt.value : this.replayedAt,
        userDismissed: userDismissed ?? this.userDismissed,
        createdAt: createdAt ?? this.createdAt,
      );
  NotificationLog copyWithCompanion(NotificationLogsCompanion data) {
    return NotificationLog(
      id: data.id.present ? data.id.value : this.id,
      reminderId:
          data.reminderId.present ? data.reminderId.value : this.reminderId,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
      firedAt: data.firedAt.present ? data.firedAt.value : this.firedAt,
      wasDnd: data.wasDnd.present ? data.wasDnd.value : this.wasDnd,
      replayedAt:
          data.replayedAt.present ? data.replayedAt.value : this.replayedAt,
      userDismissed: data.userDismissed.present
          ? data.userDismissed.value
          : this.userDismissed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationLog(')
          ..write('id: $id, ')
          ..write('reminderId: $reminderId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('firedAt: $firedAt, ')
          ..write('wasDnd: $wasDnd, ')
          ..write('replayedAt: $replayedAt, ')
          ..write('userDismissed: $userDismissed, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, reminderId, scheduledAt, firedAt, wasDnd,
      replayedAt, userDismissed, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationLog &&
          other.id == this.id &&
          other.reminderId == this.reminderId &&
          other.scheduledAt == this.scheduledAt &&
          other.firedAt == this.firedAt &&
          other.wasDnd == this.wasDnd &&
          other.replayedAt == this.replayedAt &&
          other.userDismissed == this.userDismissed &&
          other.createdAt == this.createdAt);
}

class NotificationLogsCompanion extends UpdateCompanion<NotificationLog> {
  final Value<String> id;
  final Value<String> reminderId;
  final Value<int> scheduledAt;
  final Value<int?> firedAt;
  final Value<bool> wasDnd;
  final Value<int?> replayedAt;
  final Value<bool> userDismissed;
  final Value<int> createdAt;
  final Value<int> rowid;
  const NotificationLogsCompanion({
    this.id = const Value.absent(),
    this.reminderId = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.firedAt = const Value.absent(),
    this.wasDnd = const Value.absent(),
    this.replayedAt = const Value.absent(),
    this.userDismissed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationLogsCompanion.insert({
    required String id,
    required String reminderId,
    required int scheduledAt,
    this.firedAt = const Value.absent(),
    this.wasDnd = const Value.absent(),
    this.replayedAt = const Value.absent(),
    this.userDismissed = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        reminderId = Value(reminderId),
        scheduledAt = Value(scheduledAt),
        createdAt = Value(createdAt);
  static Insertable<NotificationLog> custom({
    Expression<String>? id,
    Expression<String>? reminderId,
    Expression<int>? scheduledAt,
    Expression<int>? firedAt,
    Expression<bool>? wasDnd,
    Expression<int>? replayedAt,
    Expression<bool>? userDismissed,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reminderId != null) 'reminder_id': reminderId,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (firedAt != null) 'fired_at': firedAt,
      if (wasDnd != null) 'was_dnd': wasDnd,
      if (replayedAt != null) 'replayed_at': replayedAt,
      if (userDismissed != null) 'user_dismissed': userDismissed,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? reminderId,
      Value<int>? scheduledAt,
      Value<int?>? firedAt,
      Value<bool>? wasDnd,
      Value<int?>? replayedAt,
      Value<bool>? userDismissed,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return NotificationLogsCompanion(
      id: id ?? this.id,
      reminderId: reminderId ?? this.reminderId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      firedAt: firedAt ?? this.firedAt,
      wasDnd: wasDnd ?? this.wasDnd,
      replayedAt: replayedAt ?? this.replayedAt,
      userDismissed: userDismissed ?? this.userDismissed,
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
    if (reminderId.present) {
      map['reminder_id'] = Variable<String>(reminderId.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<int>(scheduledAt.value);
    }
    if (firedAt.present) {
      map['fired_at'] = Variable<int>(firedAt.value);
    }
    if (wasDnd.present) {
      map['was_dnd'] = Variable<bool>(wasDnd.value);
    }
    if (replayedAt.present) {
      map['replayed_at'] = Variable<int>(replayedAt.value);
    }
    if (userDismissed.present) {
      map['user_dismissed'] = Variable<bool>(userDismissed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationLogsCompanion(')
          ..write('id: $id, ')
          ..write('reminderId: $reminderId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('firedAt: $firedAt, ')
          ..write('wasDnd: $wasDnd, ')
          ..write('replayedAt: $replayedAt, ')
          ..write('userDismissed: $userDismissed, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiActionsLogsTable extends AiActionsLogs
    with TableInfo<$AiActionsLogsTable, AiActionsLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiActionsLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _inputTextMeta =
      const VerificationMeta('inputText');
  @override
  late final GeneratedColumn<String> inputText = GeneratedColumn<String>(
      'input_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rawResponseMeta =
      const VerificationMeta('rawResponse');
  @override
  late final GeneratedColumn<String> rawResponse = GeneratedColumn<String>(
      'raw_response', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parsedJsonMeta =
      const VerificationMeta('parsedJson');
  @override
  late final GeneratedColumn<String> parsedJson = GeneratedColumn<String>(
      'parsed_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _actionTakenMeta =
      const VerificationMeta('actionTaken');
  @override
  late final GeneratedColumn<String> actionTaken = GeneratedColumn<String>(
      'action_taken', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tasks (id)'));
  static const VerificationMeta _userEditedMeta =
      const VerificationMeta('userEdited');
  @override
  late final GeneratedColumn<bool> userEdited = GeneratedColumn<bool>(
      'user_edited', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("user_edited" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        inputText,
        rawResponse,
        parsedJson,
        confidence,
        actionTaken,
        taskId,
        userEdited,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_actions_logs';
  @override
  VerificationContext validateIntegrity(Insertable<AiActionsLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('input_text')) {
      context.handle(_inputTextMeta,
          inputText.isAcceptableOrUnknown(data['input_text']!, _inputTextMeta));
    } else if (isInserting) {
      context.missing(_inputTextMeta);
    }
    if (data.containsKey('raw_response')) {
      context.handle(
          _rawResponseMeta,
          rawResponse.isAcceptableOrUnknown(
              data['raw_response']!, _rawResponseMeta));
    } else if (isInserting) {
      context.missing(_rawResponseMeta);
    }
    if (data.containsKey('parsed_json')) {
      context.handle(
          _parsedJsonMeta,
          parsedJson.isAcceptableOrUnknown(
              data['parsed_json']!, _parsedJsonMeta));
    } else if (isInserting) {
      context.missing(_parsedJsonMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    }
    if (data.containsKey('action_taken')) {
      context.handle(
          _actionTakenMeta,
          actionTaken.isAcceptableOrUnknown(
              data['action_taken']!, _actionTakenMeta));
    } else if (isInserting) {
      context.missing(_actionTakenMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    }
    if (data.containsKey('user_edited')) {
      context.handle(
          _userEditedMeta,
          userEdited.isAcceptableOrUnknown(
              data['user_edited']!, _userEditedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiActionsLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiActionsLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      inputText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}input_text'])!,
      rawResponse: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_response'])!,
      parsedJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parsed_json'])!,
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence']),
      actionTaken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_taken'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id']),
      userEdited: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}user_edited'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AiActionsLogsTable createAlias(String alias) {
    return $AiActionsLogsTable(attachedDatabase, alias);
  }
}

class AiActionsLog extends DataClass implements Insertable<AiActionsLog> {
  final String id;
  final String inputText;
  final String rawResponse;
  final String parsedJson;
  final double? confidence;
  final String actionTaken;
  final String? taskId;
  final bool userEdited;
  final int createdAt;
  const AiActionsLog(
      {required this.id,
      required this.inputText,
      required this.rawResponse,
      required this.parsedJson,
      this.confidence,
      required this.actionTaken,
      this.taskId,
      required this.userEdited,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['input_text'] = Variable<String>(inputText);
    map['raw_response'] = Variable<String>(rawResponse);
    map['parsed_json'] = Variable<String>(parsedJson);
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    map['action_taken'] = Variable<String>(actionTaken);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<String>(taskId);
    }
    map['user_edited'] = Variable<bool>(userEdited);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  AiActionsLogsCompanion toCompanion(bool nullToAbsent) {
    return AiActionsLogsCompanion(
      id: Value(id),
      inputText: Value(inputText),
      rawResponse: Value(rawResponse),
      parsedJson: Value(parsedJson),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      actionTaken: Value(actionTaken),
      taskId:
          taskId == null && nullToAbsent ? const Value.absent() : Value(taskId),
      userEdited: Value(userEdited),
      createdAt: Value(createdAt),
    );
  }

  factory AiActionsLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiActionsLog(
      id: serializer.fromJson<String>(json['id']),
      inputText: serializer.fromJson<String>(json['inputText']),
      rawResponse: serializer.fromJson<String>(json['rawResponse']),
      parsedJson: serializer.fromJson<String>(json['parsedJson']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      actionTaken: serializer.fromJson<String>(json['actionTaken']),
      taskId: serializer.fromJson<String?>(json['taskId']),
      userEdited: serializer.fromJson<bool>(json['userEdited']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'inputText': serializer.toJson<String>(inputText),
      'rawResponse': serializer.toJson<String>(rawResponse),
      'parsedJson': serializer.toJson<String>(parsedJson),
      'confidence': serializer.toJson<double?>(confidence),
      'actionTaken': serializer.toJson<String>(actionTaken),
      'taskId': serializer.toJson<String?>(taskId),
      'userEdited': serializer.toJson<bool>(userEdited),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  AiActionsLog copyWith(
          {String? id,
          String? inputText,
          String? rawResponse,
          String? parsedJson,
          Value<double?> confidence = const Value.absent(),
          String? actionTaken,
          Value<String?> taskId = const Value.absent(),
          bool? userEdited,
          int? createdAt}) =>
      AiActionsLog(
        id: id ?? this.id,
        inputText: inputText ?? this.inputText,
        rawResponse: rawResponse ?? this.rawResponse,
        parsedJson: parsedJson ?? this.parsedJson,
        confidence: confidence.present ? confidence.value : this.confidence,
        actionTaken: actionTaken ?? this.actionTaken,
        taskId: taskId.present ? taskId.value : this.taskId,
        userEdited: userEdited ?? this.userEdited,
        createdAt: createdAt ?? this.createdAt,
      );
  AiActionsLog copyWithCompanion(AiActionsLogsCompanion data) {
    return AiActionsLog(
      id: data.id.present ? data.id.value : this.id,
      inputText: data.inputText.present ? data.inputText.value : this.inputText,
      rawResponse:
          data.rawResponse.present ? data.rawResponse.value : this.rawResponse,
      parsedJson:
          data.parsedJson.present ? data.parsedJson.value : this.parsedJson,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      actionTaken:
          data.actionTaken.present ? data.actionTaken.value : this.actionTaken,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      userEdited:
          data.userEdited.present ? data.userEdited.value : this.userEdited,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiActionsLog(')
          ..write('id: $id, ')
          ..write('inputText: $inputText, ')
          ..write('rawResponse: $rawResponse, ')
          ..write('parsedJson: $parsedJson, ')
          ..write('confidence: $confidence, ')
          ..write('actionTaken: $actionTaken, ')
          ..write('taskId: $taskId, ')
          ..write('userEdited: $userEdited, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, inputText, rawResponse, parsedJson,
      confidence, actionTaken, taskId, userEdited, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiActionsLog &&
          other.id == this.id &&
          other.inputText == this.inputText &&
          other.rawResponse == this.rawResponse &&
          other.parsedJson == this.parsedJson &&
          other.confidence == this.confidence &&
          other.actionTaken == this.actionTaken &&
          other.taskId == this.taskId &&
          other.userEdited == this.userEdited &&
          other.createdAt == this.createdAt);
}

class AiActionsLogsCompanion extends UpdateCompanion<AiActionsLog> {
  final Value<String> id;
  final Value<String> inputText;
  final Value<String> rawResponse;
  final Value<String> parsedJson;
  final Value<double?> confidence;
  final Value<String> actionTaken;
  final Value<String?> taskId;
  final Value<bool> userEdited;
  final Value<int> createdAt;
  final Value<int> rowid;
  const AiActionsLogsCompanion({
    this.id = const Value.absent(),
    this.inputText = const Value.absent(),
    this.rawResponse = const Value.absent(),
    this.parsedJson = const Value.absent(),
    this.confidence = const Value.absent(),
    this.actionTaken = const Value.absent(),
    this.taskId = const Value.absent(),
    this.userEdited = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiActionsLogsCompanion.insert({
    required String id,
    required String inputText,
    required String rawResponse,
    required String parsedJson,
    this.confidence = const Value.absent(),
    required String actionTaken,
    this.taskId = const Value.absent(),
    this.userEdited = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        inputText = Value(inputText),
        rawResponse = Value(rawResponse),
        parsedJson = Value(parsedJson),
        actionTaken = Value(actionTaken),
        createdAt = Value(createdAt);
  static Insertable<AiActionsLog> custom({
    Expression<String>? id,
    Expression<String>? inputText,
    Expression<String>? rawResponse,
    Expression<String>? parsedJson,
    Expression<double>? confidence,
    Expression<String>? actionTaken,
    Expression<String>? taskId,
    Expression<bool>? userEdited,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (inputText != null) 'input_text': inputText,
      if (rawResponse != null) 'raw_response': rawResponse,
      if (parsedJson != null) 'parsed_json': parsedJson,
      if (confidence != null) 'confidence': confidence,
      if (actionTaken != null) 'action_taken': actionTaken,
      if (taskId != null) 'task_id': taskId,
      if (userEdited != null) 'user_edited': userEdited,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiActionsLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? inputText,
      Value<String>? rawResponse,
      Value<String>? parsedJson,
      Value<double?>? confidence,
      Value<String>? actionTaken,
      Value<String?>? taskId,
      Value<bool>? userEdited,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return AiActionsLogsCompanion(
      id: id ?? this.id,
      inputText: inputText ?? this.inputText,
      rawResponse: rawResponse ?? this.rawResponse,
      parsedJson: parsedJson ?? this.parsedJson,
      confidence: confidence ?? this.confidence,
      actionTaken: actionTaken ?? this.actionTaken,
      taskId: taskId ?? this.taskId,
      userEdited: userEdited ?? this.userEdited,
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
    if (inputText.present) {
      map['input_text'] = Variable<String>(inputText.value);
    }
    if (rawResponse.present) {
      map['raw_response'] = Variable<String>(rawResponse.value);
    }
    if (parsedJson.present) {
      map['parsed_json'] = Variable<String>(parsedJson.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (actionTaken.present) {
      map['action_taken'] = Variable<String>(actionTaken.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (userEdited.present) {
      map['user_edited'] = Variable<bool>(userEdited.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiActionsLogsCompanion(')
          ..write('id: $id, ')
          ..write('inputText: $inputText, ')
          ..write('rawResponse: $rawResponse, ')
          ..write('parsedJson: $parsedJson, ')
          ..write('confidence: $confidence, ')
          ..write('actionTaken: $actionTaken, ')
          ..write('taskId: $taskId, ')
          ..write('userEdited: $userEdited, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OfflineQueuesTable extends OfflineQueues
    with TableInfo<$OfflineQueuesTable, OfflineQueue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineQueuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('transcript'));
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contextJsonMeta =
      const VerificationMeta('contextJson');
  @override
  late final GeneratedColumn<String> contextJson = GeneratedColumn<String>(
      'context_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _processedAtMeta =
      const VerificationMeta('processedAt');
  @override
  late final GeneratedColumn<int> processedAt = GeneratedColumn<int>(
      'processed_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        content,
        contextJson,
        status,
        attempts,
        createdAt,
        processedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_queues';
  @override
  VerificationContext validateIntegrity(Insertable<OfflineQueue> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('context_json')) {
      context.handle(
          _contextJsonMeta,
          contextJson.isAcceptableOrUnknown(
              data['context_json']!, _contextJsonMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('processed_at')) {
      context.handle(
          _processedAtMeta,
          processedAt.isAcceptableOrUnknown(
              data['processed_at']!, _processedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineQueue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineQueue(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      contextJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}context_json']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      processedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}processed_at']),
    );
  }

  @override
  $OfflineQueuesTable createAlias(String alias) {
    return $OfflineQueuesTable(attachedDatabase, alias);
  }
}

class OfflineQueue extends DataClass implements Insertable<OfflineQueue> {
  final String id;
  final String type;
  final String content;
  final String? contextJson;
  final String status;
  final int attempts;
  final int createdAt;
  final int? processedAt;
  const OfflineQueue(
      {required this.id,
      required this.type,
      required this.content,
      this.contextJson,
      required this.status,
      required this.attempts,
      required this.createdAt,
      this.processedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || contextJson != null) {
      map['context_json'] = Variable<String>(contextJson);
    }
    map['status'] = Variable<String>(status);
    map['attempts'] = Variable<int>(attempts);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || processedAt != null) {
      map['processed_at'] = Variable<int>(processedAt);
    }
    return map;
  }

  OfflineQueuesCompanion toCompanion(bool nullToAbsent) {
    return OfflineQueuesCompanion(
      id: Value(id),
      type: Value(type),
      content: Value(content),
      contextJson: contextJson == null && nullToAbsent
          ? const Value.absent()
          : Value(contextJson),
      status: Value(status),
      attempts: Value(attempts),
      createdAt: Value(createdAt),
      processedAt: processedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(processedAt),
    );
  }

  factory OfflineQueue.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineQueue(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      content: serializer.fromJson<String>(json['content']),
      contextJson: serializer.fromJson<String?>(json['contextJson']),
      status: serializer.fromJson<String>(json['status']),
      attempts: serializer.fromJson<int>(json['attempts']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      processedAt: serializer.fromJson<int?>(json['processedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'content': serializer.toJson<String>(content),
      'contextJson': serializer.toJson<String?>(contextJson),
      'status': serializer.toJson<String>(status),
      'attempts': serializer.toJson<int>(attempts),
      'createdAt': serializer.toJson<int>(createdAt),
      'processedAt': serializer.toJson<int?>(processedAt),
    };
  }

  OfflineQueue copyWith(
          {String? id,
          String? type,
          String? content,
          Value<String?> contextJson = const Value.absent(),
          String? status,
          int? attempts,
          int? createdAt,
          Value<int?> processedAt = const Value.absent()}) =>
      OfflineQueue(
        id: id ?? this.id,
        type: type ?? this.type,
        content: content ?? this.content,
        contextJson: contextJson.present ? contextJson.value : this.contextJson,
        status: status ?? this.status,
        attempts: attempts ?? this.attempts,
        createdAt: createdAt ?? this.createdAt,
        processedAt: processedAt.present ? processedAt.value : this.processedAt,
      );
  OfflineQueue copyWithCompanion(OfflineQueuesCompanion data) {
    return OfflineQueue(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      content: data.content.present ? data.content.value : this.content,
      contextJson:
          data.contextJson.present ? data.contextJson.value : this.contextJson,
      status: data.status.present ? data.status.value : this.status,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      processedAt:
          data.processedAt.present ? data.processedAt.value : this.processedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineQueue(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('contextJson: $contextJson, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('processedAt: $processedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, type, content, contextJson, status, attempts, createdAt, processedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineQueue &&
          other.id == this.id &&
          other.type == this.type &&
          other.content == this.content &&
          other.contextJson == this.contextJson &&
          other.status == this.status &&
          other.attempts == this.attempts &&
          other.createdAt == this.createdAt &&
          other.processedAt == this.processedAt);
}

class OfflineQueuesCompanion extends UpdateCompanion<OfflineQueue> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> content;
  final Value<String?> contextJson;
  final Value<String> status;
  final Value<int> attempts;
  final Value<int> createdAt;
  final Value<int?> processedAt;
  final Value<int> rowid;
  const OfflineQueuesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.content = const Value.absent(),
    this.contextJson = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.processedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfflineQueuesCompanion.insert({
    required String id,
    this.type = const Value.absent(),
    required String content,
    this.contextJson = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    required int createdAt,
    this.processedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        content = Value(content),
        createdAt = Value(createdAt);
  static Insertable<OfflineQueue> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? content,
    Expression<String>? contextJson,
    Expression<String>? status,
    Expression<int>? attempts,
    Expression<int>? createdAt,
    Expression<int>? processedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (content != null) 'content': content,
      if (contextJson != null) 'context_json': contextJson,
      if (status != null) 'status': status,
      if (attempts != null) 'attempts': attempts,
      if (createdAt != null) 'created_at': createdAt,
      if (processedAt != null) 'processed_at': processedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OfflineQueuesCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String>? content,
      Value<String?>? contextJson,
      Value<String>? status,
      Value<int>? attempts,
      Value<int>? createdAt,
      Value<int?>? processedAt,
      Value<int>? rowid}) {
    return OfflineQueuesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      contextJson: contextJson ?? this.contextJson,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (contextJson.present) {
      map['context_json'] = Variable<String>(contextJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (processedAt.present) {
      map['processed_at'] = Variable<int>(processedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineQueuesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('contextJson: $contextJson, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('processedAt: $processedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyLogsTable extends DailyLogs
    with TableInfo<$DailyLogsTable, DailyLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tasks (id)'));
  static const VerificationMeta _logDateMeta =
      const VerificationMeta('logDate');
  @override
  late final GeneratedColumn<int> logDate = GeneratedColumn<int>(
      'log_date', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _doneAtMeta = const VerificationMeta('doneAt');
  @override
  late final GeneratedColumn<int> doneAt = GeneratedColumn<int>(
      'done_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, taskId, logDate, status, doneAt, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_logs';
  @override
  VerificationContext validateIntegrity(Insertable<DailyLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('log_date')) {
      context.handle(_logDateMeta,
          logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta));
    } else if (isInserting) {
      context.missing(_logDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('done_at')) {
      context.handle(_doneAtMeta,
          doneAt.isAcceptableOrUnknown(data['done_at']!, _doneAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id'])!,
      logDate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}log_date'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      doneAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}done_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $DailyLogsTable createAlias(String alias) {
    return $DailyLogsTable(attachedDatabase, alias);
  }
}

class DailyLog extends DataClass implements Insertable<DailyLog> {
  final String id;
  final String taskId;
  final int logDate;
  final String status;
  final int? doneAt;
  final int createdAt;
  const DailyLog(
      {required this.id,
      required this.taskId,
      required this.logDate,
      required this.status,
      this.doneAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['log_date'] = Variable<int>(logDate);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || doneAt != null) {
      map['done_at'] = Variable<int>(doneAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  DailyLogsCompanion toCompanion(bool nullToAbsent) {
    return DailyLogsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      logDate: Value(logDate),
      status: Value(status),
      doneAt:
          doneAt == null && nullToAbsent ? const Value.absent() : Value(doneAt),
      createdAt: Value(createdAt),
    );
  }

  factory DailyLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyLog(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      logDate: serializer.fromJson<int>(json['logDate']),
      status: serializer.fromJson<String>(json['status']),
      doneAt: serializer.fromJson<int?>(json['doneAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'logDate': serializer.toJson<int>(logDate),
      'status': serializer.toJson<String>(status),
      'doneAt': serializer.toJson<int?>(doneAt),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  DailyLog copyWith(
          {String? id,
          String? taskId,
          int? logDate,
          String? status,
          Value<int?> doneAt = const Value.absent(),
          int? createdAt}) =>
      DailyLog(
        id: id ?? this.id,
        taskId: taskId ?? this.taskId,
        logDate: logDate ?? this.logDate,
        status: status ?? this.status,
        doneAt: doneAt.present ? doneAt.value : this.doneAt,
        createdAt: createdAt ?? this.createdAt,
      );
  DailyLog copyWithCompanion(DailyLogsCompanion data) {
    return DailyLog(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
      status: data.status.present ? data.status.value : this.status,
      doneAt: data.doneAt.present ? data.doneAt.value : this.doneAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyLog(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('logDate: $logDate, ')
          ..write('status: $status, ')
          ..write('doneAt: $doneAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, taskId, logDate, status, doneAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyLog &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.logDate == this.logDate &&
          other.status == this.status &&
          other.doneAt == this.doneAt &&
          other.createdAt == this.createdAt);
}

class DailyLogsCompanion extends UpdateCompanion<DailyLog> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<int> logDate;
  final Value<String> status;
  final Value<int?> doneAt;
  final Value<int> createdAt;
  final Value<int> rowid;
  const DailyLogsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.logDate = const Value.absent(),
    this.status = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyLogsCompanion.insert({
    required String id,
    required String taskId,
    required int logDate,
    required String status,
    this.doneAt = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        taskId = Value(taskId),
        logDate = Value(logDate),
        status = Value(status),
        createdAt = Value(createdAt);
  static Insertable<DailyLog> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<int>? logDate,
    Expression<String>? status,
    Expression<int>? doneAt,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (logDate != null) 'log_date': logDate,
      if (status != null) 'status': status,
      if (doneAt != null) 'done_at': doneAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? taskId,
      Value<int>? logDate,
      Value<String>? status,
      Value<int?>? doneAt,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return DailyLogsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      logDate: logDate ?? this.logDate,
      status: status ?? this.status,
      doneAt: doneAt ?? this.doneAt,
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
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<int>(logDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (doneAt.present) {
      map['done_at'] = Variable<int>(doneAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyLogsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('logDate: $logDate, ')
          ..write('status: $status, ')
          ..write('doneAt: $doneAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueuesTable extends SyncQueues
    with TableInfo<$SyncQueuesTable, SyncQueue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityType,
        entityId,
        operation,
        payload,
        status,
        attempts,
        createdAt,
        syncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queues';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueue> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueue(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}synced_at']),
    );
  }

  @override
  $SyncQueuesTable createAlias(String alias) {
    return $SyncQueuesTable(attachedDatabase, alias);
  }
}

class SyncQueue extends DataClass implements Insertable<SyncQueue> {
  final String id;
  final String entityType;
  final String entityId;
  final String operation;
  final String payload;
  final String status;
  final int attempts;
  final int createdAt;
  final int? syncedAt;
  const SyncQueue(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.operation,
      required this.payload,
      required this.status,
      required this.attempts,
      required this.createdAt,
      this.syncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['status'] = Variable<String>(status);
    map['attempts'] = Variable<int>(attempts);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<int>(syncedAt);
    }
    return map;
  }

  SyncQueuesCompanion toCompanion(bool nullToAbsent) {
    return SyncQueuesCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payload: Value(payload),
      status: Value(status),
      attempts: Value(attempts),
      createdAt: Value(createdAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory SyncQueue.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueue(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
      attempts: serializer.fromJson<int>(json['attempts']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      syncedAt: serializer.fromJson<int?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(status),
      'attempts': serializer.toJson<int>(attempts),
      'createdAt': serializer.toJson<int>(createdAt),
      'syncedAt': serializer.toJson<int?>(syncedAt),
    };
  }

  SyncQueue copyWith(
          {String? id,
          String? entityType,
          String? entityId,
          String? operation,
          String? payload,
          String? status,
          int? attempts,
          int? createdAt,
          Value<int?> syncedAt = const Value.absent()}) =>
      SyncQueue(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        operation: operation ?? this.operation,
        payload: payload ?? this.payload,
        status: status ?? this.status,
        attempts: attempts ?? this.attempts,
        createdAt: createdAt ?? this.createdAt,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
      );
  SyncQueue copyWithCompanion(SyncQueuesCompanion data) {
    return SyncQueue(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueue(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityType, entityId, operation, payload,
      status, attempts, createdAt, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueue &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.attempts == this.attempts &&
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt);
}

class SyncQueuesCompanion extends UpdateCompanion<SyncQueue> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<String> status;
  final Value<int> attempts;
  final Value<int> createdAt;
  final Value<int?> syncedAt;
  final Value<int> rowid;
  const SyncQueuesCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueuesCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    required int createdAt,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entityType = Value(entityType),
        entityId = Value(entityId),
        operation = Value(operation),
        payload = Value(payload),
        createdAt = Value(createdAt);
  static Insertable<SyncQueue> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<int>? attempts,
    Expression<int>? createdAt,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (attempts != null) 'attempts': attempts,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueuesCompanion copyWith(
      {Value<String>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? operation,
      Value<String>? payload,
      Value<String>? status,
      Value<int>? attempts,
      Value<int>? createdAt,
      Value<int?>? syncedAt,
      Value<int>? rowid}) {
    return SyncQueuesCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<int>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueuesCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WorkspacesTable workspaces = $WorkspacesTable(this);
  late final $WorkspaceSectionsTable workspaceSections =
      $WorkspaceSectionsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $EventsTable events = $EventsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $SharedContentsTable sharedContents = $SharedContentsTable(this);
  late final $NotificationLogsTable notificationLogs =
      $NotificationLogsTable(this);
  late final $AiActionsLogsTable aiActionsLogs = $AiActionsLogsTable(this);
  late final $OfflineQueuesTable offlineQueues = $OfflineQueuesTable(this);
  late final $DailyLogsTable dailyLogs = $DailyLogsTable(this);
  late final $SyncQueuesTable syncQueues = $SyncQueuesTable(this);
  late final TaskDao taskDao = TaskDao(this as AppDatabase);
  late final WorkspaceDao workspaceDao = WorkspaceDao(this as AppDatabase);
  late final ReminderDao reminderDao = ReminderDao(this as AppDatabase);
  late final EventDao eventDao = EventDao(this as AppDatabase);
  late final NotificationDao notificationDao =
      NotificationDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        workspaces,
        workspaceSections,
        tasks,
        events,
        reminders,
        notes,
        sharedContents,
        notificationLogs,
        aiActionsLogs,
        offlineQueues,
        dailyLogs,
        syncQueues
      ];
}

typedef $$WorkspacesTableCreateCompanionBuilder = WorkspacesCompanion Function({
  required String id,
  required String name,
  Value<String> colorHex,
  Value<String> iconKey,
  Value<int> sortOrder,
  Value<String> createdBy,
  Value<bool> isArchived,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$WorkspacesTableUpdateCompanionBuilder = WorkspacesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> colorHex,
  Value<String> iconKey,
  Value<int> sortOrder,
  Value<String> createdBy,
  Value<bool> isArchived,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});

final class $$WorkspacesTableReferences
    extends BaseReferences<_$AppDatabase, $WorkspacesTable, Workspace> {
  $$WorkspacesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorkspaceSectionsTable, List<WorkspaceSection>>
      _workspaceSectionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.workspaceSections,
              aliasName: $_aliasNameGenerator(
                  db.workspaces.id, db.workspaceSections.workspaceId));

  $$WorkspaceSectionsTableProcessedTableManager get workspaceSectionsRefs {
    final manager = $$WorkspaceSectionsTableTableManager(
            $_db, $_db.workspaceSections)
        .filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_workspaceSectionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.tasks,
          aliasName:
              $_aliasNameGenerator(db.workspaces.id, db.tasks.workspaceId));

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$EventsTable, List<Event>> _eventsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.events,
          aliasName:
              $_aliasNameGenerator(db.workspaces.id, db.events.workspaceId));

  $$EventsTableProcessedTableManager get eventsRefs {
    final manager = $$EventsTableTableManager($_db, $_db.events)
        .filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$NotesTable, List<Note>> _notesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.notes,
          aliasName:
              $_aliasNameGenerator(db.workspaces.id, db.notes.workspaceId));

  $$NotesTableProcessedTableManager get notesRefs {
    final manager = $$NotesTableTableManager($_db, $_db.notes)
        .filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_notesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SharedContentsTable, List<SharedContent>>
      _sharedContentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.sharedContents,
              aliasName: $_aliasNameGenerator(
                  db.workspaces.id, db.sharedContents.workspaceId));

  $$SharedContentsTableProcessedTableManager get sharedContentsRefs {
    final manager = $$SharedContentsTableTableManager($_db, $_db.sharedContents)
        .filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sharedContentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$WorkspacesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconKey => $composableBuilder(
      column: $table.iconKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> workspaceSectionsRefs(
      Expression<bool> Function($$WorkspaceSectionsTableFilterComposer f) f) {
    final $$WorkspaceSectionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workspaceSections,
        getReferencedColumn: (t) => t.workspaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkspaceSectionsTableFilterComposer(
              $db: $db,
              $table: $db.workspaceSections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> tasksRefs(
      Expression<bool> Function($$TasksTableFilterComposer f) f) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.workspaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> eventsRefs(
      Expression<bool> Function($$EventsTableFilterComposer f) f) {
    final $$EventsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.events,
        getReferencedColumn: (t) => t.workspaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EventsTableFilterComposer(
              $db: $db,
              $table: $db.events,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> notesRefs(
      Expression<bool> Function($$NotesTableFilterComposer f) f) {
    final $$NotesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.notes,
        getReferencedColumn: (t) => t.workspaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NotesTableFilterComposer(
              $db: $db,
              $table: $db.notes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> sharedContentsRefs(
      Expression<bool> Function($$SharedContentsTableFilterComposer f) f) {
    final $$SharedContentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sharedContents,
        getReferencedColumn: (t) => t.workspaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SharedContentsTableFilterComposer(
              $db: $db,
              $table: $db.sharedContents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WorkspacesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconKey => $composableBuilder(
      column: $table.iconKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$WorkspacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> workspaceSectionsRefs<T extends Object>(
      Expression<T> Function($$WorkspaceSectionsTableAnnotationComposer a) f) {
    final $$WorkspaceSectionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.workspaceSections,
            getReferencedColumn: (t) => t.workspaceId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$WorkspaceSectionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.workspaceSections,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> tasksRefs<T extends Object>(
      Expression<T> Function($$TasksTableAnnotationComposer a) f) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.workspaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> eventsRefs<T extends Object>(
      Expression<T> Function($$EventsTableAnnotationComposer a) f) {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.events,
        getReferencedColumn: (t) => t.workspaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EventsTableAnnotationComposer(
              $db: $db,
              $table: $db.events,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> notesRefs<T extends Object>(
      Expression<T> Function($$NotesTableAnnotationComposer a) f) {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.notes,
        getReferencedColumn: (t) => t.workspaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NotesTableAnnotationComposer(
              $db: $db,
              $table: $db.notes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> sharedContentsRefs<T extends Object>(
      Expression<T> Function($$SharedContentsTableAnnotationComposer a) f) {
    final $$SharedContentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sharedContents,
        getReferencedColumn: (t) => t.workspaceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SharedContentsTableAnnotationComposer(
              $db: $db,
              $table: $db.sharedContents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WorkspacesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkspacesTable,
    Workspace,
    $$WorkspacesTableFilterComposer,
    $$WorkspacesTableOrderingComposer,
    $$WorkspacesTableAnnotationComposer,
    $$WorkspacesTableCreateCompanionBuilder,
    $$WorkspacesTableUpdateCompanionBuilder,
    (Workspace, $$WorkspacesTableReferences),
    Workspace,
    PrefetchHooks Function(
        {bool workspaceSectionsRefs,
        bool tasksRefs,
        bool eventsRefs,
        bool notesRefs,
        bool sharedContentsRefs})> {
  $$WorkspacesTableTableManager(_$AppDatabase db, $WorkspacesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkspacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkspacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkspacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> colorHex = const Value.absent(),
            Value<String> iconKey = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkspacesCompanion(
            id: id,
            name: name,
            colorHex: colorHex,
            iconKey: iconKey,
            sortOrder: sortOrder,
            createdBy: createdBy,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String> colorHex = const Value.absent(),
            Value<String> iconKey = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkspacesCompanion.insert(
            id: id,
            name: name,
            colorHex: colorHex,
            iconKey: iconKey,
            sortOrder: sortOrder,
            createdBy: createdBy,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WorkspacesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {workspaceSectionsRefs = false,
              tasksRefs = false,
              eventsRefs = false,
              notesRefs = false,
              sharedContentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (workspaceSectionsRefs) db.workspaceSections,
                if (tasksRefs) db.tasks,
                if (eventsRefs) db.events,
                if (notesRefs) db.notes,
                if (sharedContentsRefs) db.sharedContents
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workspaceSectionsRefs)
                    await $_getPrefetchedData<Workspace, $WorkspacesTable,
                            WorkspaceSection>(
                        currentTable: table,
                        referencedTable: $$WorkspacesTableReferences
                            ._workspaceSectionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WorkspacesTableReferences(db, table, p0)
                                .workspaceSectionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workspaceId == item.id),
                        typedResults: items),
                  if (tasksRefs)
                    await $_getPrefetchedData<Workspace, $WorkspacesTable,
                            Task>(
                        currentTable: table,
                        referencedTable:
                            $$WorkspacesTableReferences._tasksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WorkspacesTableReferences(db, table, p0)
                                .tasksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workspaceId == item.id),
                        typedResults: items),
                  if (eventsRefs)
                    await $_getPrefetchedData<Workspace, $WorkspacesTable,
                            Event>(
                        currentTable: table,
                        referencedTable:
                            $$WorkspacesTableReferences._eventsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WorkspacesTableReferences(db, table, p0)
                                .eventsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workspaceId == item.id),
                        typedResults: items),
                  if (notesRefs)
                    await $_getPrefetchedData<Workspace, $WorkspacesTable,
                            Note>(
                        currentTable: table,
                        referencedTable:
                            $$WorkspacesTableReferences._notesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WorkspacesTableReferences(db, table, p0)
                                .notesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workspaceId == item.id),
                        typedResults: items),
                  if (sharedContentsRefs)
                    await $_getPrefetchedData<Workspace, $WorkspacesTable,
                            SharedContent>(
                        currentTable: table,
                        referencedTable: $$WorkspacesTableReferences
                            ._sharedContentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WorkspacesTableReferences(db, table, p0)
                                .sharedContentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workspaceId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$WorkspacesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkspacesTable,
    Workspace,
    $$WorkspacesTableFilterComposer,
    $$WorkspacesTableOrderingComposer,
    $$WorkspacesTableAnnotationComposer,
    $$WorkspacesTableCreateCompanionBuilder,
    $$WorkspacesTableUpdateCompanionBuilder,
    (Workspace, $$WorkspacesTableReferences),
    Workspace,
    PrefetchHooks Function(
        {bool workspaceSectionsRefs,
        bool tasksRefs,
        bool eventsRefs,
        bool notesRefs,
        bool sharedContentsRefs})>;
typedef $$WorkspaceSectionsTableCreateCompanionBuilder
    = WorkspaceSectionsCompanion Function({
  required String id,
  required String workspaceId,
  required String name,
  Value<int> sortOrder,
  Value<String> createdBy,
  Value<bool> isArchived,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$WorkspaceSectionsTableUpdateCompanionBuilder
    = WorkspaceSectionsCompanion Function({
  Value<String> id,
  Value<String> workspaceId,
  Value<String> name,
  Value<int> sortOrder,
  Value<String> createdBy,
  Value<bool> isArchived,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});

final class $$WorkspaceSectionsTableReferences extends BaseReferences<
    _$AppDatabase, $WorkspaceSectionsTable, WorkspaceSection> {
  $$WorkspaceSectionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.workspaces.createAlias($_aliasNameGenerator(
          db.workspaceSections.workspaceId, db.workspaces.id));

  $$WorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<String>('workspace_id')!;

    final manager = $$WorkspacesTableTableManager($_db, $_db.workspaces)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.tasks,
          aliasName: $_aliasNameGenerator(
              db.workspaceSections.id, db.tasks.sectionId));

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.sectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$EventsTable, List<Event>> _eventsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.events,
          aliasName: $_aliasNameGenerator(
              db.workspaceSections.id, db.events.sectionId));

  $$EventsTableProcessedTableManager get eventsRefs {
    final manager = $$EventsTableTableManager($_db, $_db.events)
        .filter((f) => f.sectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$WorkspaceSectionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkspaceSectionsTable> {
  $$WorkspaceSectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.workspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkspacesTableFilterComposer(
              $db: $db,
              $table: $db.workspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> tasksRefs(
      Expression<bool> Function($$TasksTableFilterComposer f) f) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.sectionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> eventsRefs(
      Expression<bool> Function($$EventsTableFilterComposer f) f) {
    final $$EventsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.events,
        getReferencedColumn: (t) => t.sectionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EventsTableFilterComposer(
              $db: $db,
              $table: $db.events,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WorkspaceSectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkspaceSectionsTable> {
  $$WorkspaceSectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.workspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkspacesTableOrderingComposer(
              $db: $db,
              $table: $db.workspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkspaceSectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkspaceSectionsTable> {
  $$WorkspaceSectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.workspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkspacesTableAnnotationComposer(
              $db: $db,
              $table: $db.workspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> tasksRefs<T extends Object>(
      Expression<T> Function($$TasksTableAnnotationComposer a) f) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.sectionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> eventsRefs<T extends Object>(
      Expression<T> Function($$EventsTableAnnotationComposer a) f) {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.events,
        getReferencedColumn: (t) => t.sectionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EventsTableAnnotationComposer(
              $db: $db,
              $table: $db.events,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WorkspaceSectionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkspaceSectionsTable,
    WorkspaceSection,
    $$WorkspaceSectionsTableFilterComposer,
    $$WorkspaceSectionsTableOrderingComposer,
    $$WorkspaceSectionsTableAnnotationComposer,
    $$WorkspaceSectionsTableCreateCompanionBuilder,
    $$WorkspaceSectionsTableUpdateCompanionBuilder,
    (WorkspaceSection, $$WorkspaceSectionsTableReferences),
    WorkspaceSection,
    PrefetchHooks Function(
        {bool workspaceId, bool tasksRefs, bool eventsRefs})> {
  $$WorkspaceSectionsTableTableManager(
      _$AppDatabase db, $WorkspaceSectionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkspaceSectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkspaceSectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkspaceSectionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> workspaceId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkspaceSectionsCompanion(
            id: id,
            workspaceId: workspaceId,
            name: name,
            sortOrder: sortOrder,
            createdBy: createdBy,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String workspaceId,
            required String name,
            Value<int> sortOrder = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkspaceSectionsCompanion.insert(
            id: id,
            workspaceId: workspaceId,
            name: name,
            sortOrder: sortOrder,
            createdBy: createdBy,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WorkspaceSectionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {workspaceId = false, tasksRefs = false, eventsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (tasksRefs) db.tasks,
                if (eventsRefs) db.events
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (workspaceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workspaceId,
                    referencedTable: $$WorkspaceSectionsTableReferences
                        ._workspaceIdTable(db),
                    referencedColumn: $$WorkspaceSectionsTableReferences
                        ._workspaceIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tasksRefs)
                    await $_getPrefetchedData<WorkspaceSection,
                            $WorkspaceSectionsTable, Task>(
                        currentTable: table,
                        referencedTable: $$WorkspaceSectionsTableReferences
                            ._tasksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WorkspaceSectionsTableReferences(db, table, p0)
                                .tasksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sectionId == item.id),
                        typedResults: items),
                  if (eventsRefs)
                    await $_getPrefetchedData<WorkspaceSection,
                            $WorkspaceSectionsTable, Event>(
                        currentTable: table,
                        referencedTable: $$WorkspaceSectionsTableReferences
                            ._eventsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WorkspaceSectionsTableReferences(db, table, p0)
                                .eventsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sectionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$WorkspaceSectionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkspaceSectionsTable,
    WorkspaceSection,
    $$WorkspaceSectionsTableFilterComposer,
    $$WorkspaceSectionsTableOrderingComposer,
    $$WorkspaceSectionsTableAnnotationComposer,
    $$WorkspaceSectionsTableCreateCompanionBuilder,
    $$WorkspaceSectionsTableUpdateCompanionBuilder,
    (WorkspaceSection, $$WorkspaceSectionsTableReferences),
    WorkspaceSection,
    PrefetchHooks Function(
        {bool workspaceId, bool tasksRefs, bool eventsRefs})>;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String workspaceId,
  Value<String?> sectionId,
  Value<String?> parentTaskId,
  required String name,
  Value<String?> description,
  Value<int?> deadline,
  Value<double?> estimatedHours,
  Value<String> priority,
  Value<String> status,
  Value<bool> isRecurring,
  Value<String?> recurrenceType,
  Value<String?> recurrenceDays,
  Value<int?> recurrenceStart,
  Value<int?> recurrenceEnd,
  Value<String?> contact,
  Value<String?> voiceNotePath,
  Value<String> source,
  Value<String?> aiRawTranscript,
  Value<bool> aiGenerated,
  Value<int?> completedAt,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> workspaceId,
  Value<String?> sectionId,
  Value<String?> parentTaskId,
  Value<String> name,
  Value<String?> description,
  Value<int?> deadline,
  Value<double?> estimatedHours,
  Value<String> priority,
  Value<String> status,
  Value<bool> isRecurring,
  Value<String?> recurrenceType,
  Value<String?> recurrenceDays,
  Value<int?> recurrenceStart,
  Value<int?> recurrenceEnd,
  Value<String?> contact,
  Value<String?> voiceNotePath,
  Value<String> source,
  Value<String?> aiRawTranscript,
  Value<bool> aiGenerated,
  Value<int?> completedAt,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.workspaces.createAlias(
          $_aliasNameGenerator(db.tasks.workspaceId, db.workspaces.id));

  $$WorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<String>('workspace_id')!;

    final manager = $$WorkspacesTableTableManager($_db, $_db.workspaces)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $WorkspaceSectionsTable _sectionIdTable(_$AppDatabase db) =>
      db.workspaceSections.createAlias(
          $_aliasNameGenerator(db.tasks.sectionId, db.workspaceSections.id));

  $$WorkspaceSectionsTableProcessedTableManager? get sectionId {
    final $_column = $_itemColumn<String>('section_id');
    if ($_column == null) return null;
    final manager =
        $$WorkspaceSectionsTableTableManager($_db, $_db.workspaceSections)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$RemindersTable, List<Reminder>>
      _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.reminders,
          aliasName: $_aliasNameGenerator(db.tasks.id, db.reminders.taskId));

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager($_db, $_db.reminders)
        .filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$NotesTable, List<Note>> _notesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.notes,
          aliasName: $_aliasNameGenerator(db.tasks.id, db.notes.taskId));

  $$NotesTableProcessedTableManager get notesRefs {
    final manager = $$NotesTableTableManager($_db, $_db.notes)
        .filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_notesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SharedContentsTable, List<SharedContent>>
      _sharedContentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.sharedContents,
              aliasName:
                  $_aliasNameGenerator(db.tasks.id, db.sharedContents.taskId));

  $$SharedContentsTableProcessedTableManager get sharedContentsRefs {
    final manager = $$SharedContentsTableTableManager($_db, $_db.sharedContents)
        .filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sharedContentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AiActionsLogsTable, List<AiActionsLog>>
      _aiActionsLogsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.aiActionsLogs,
              aliasName:
                  $_aliasNameGenerator(db.tasks.id, db.aiActionsLogs.taskId));

  $$AiActionsLogsTableProcessedTableManager get aiActionsLogsRefs {
    final manager = $$AiActionsLogsTableTableManager($_db, $_db.aiActionsLogs)
        .filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_aiActionsLogsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DailyLogsTable, List<DailyLog>>
      _dailyLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.dailyLogs,
          aliasName: $_aliasNameGenerator(db.tasks.id, db.dailyLogs.taskId));

  $$DailyLogsTableProcessedTableManager get dailyLogsRefs {
    final manager = $$DailyLogsTableTableManager($_db, $_db.dailyLogs)
        .filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_dailyLogsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentTaskId => $composableBuilder(
      column: $table.parentTaskId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get estimatedHours => $composableBuilder(
      column: $table.estimatedHours,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurrenceType => $composableBuilder(
      column: $table.recurrenceType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurrenceDays => $composableBuilder(
      column: $table.recurrenceDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recurrenceStart => $composableBuilder(
      column: $table.recurrenceStart,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recurrenceEnd => $composableBuilder(
      column: $table.recurrenceEnd, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contact => $composableBuilder(
      column: $table.contact, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get voiceNotePath => $composableBuilder(
      column: $table.voiceNotePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aiRawTranscript => $composableBuilder(
      column: $table.aiRawTranscript,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get aiGenerated => $composableBuilder(
      column: $table.aiGenerated, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.workspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkspacesTableFilterComposer(
              $db: $db,
              $table: $db.workspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkspaceSectionsTableFilterComposer get sectionId {
    final $$WorkspaceSectionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sectionId,
        referencedTable: $db.workspaceSections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkspaceSectionsTableFilterComposer(
              $db: $db,
              $table: $db.workspaceSections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> remindersRefs(
      Expression<bool> Function($$RemindersTableFilterComposer f) f) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reminders,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RemindersTableFilterComposer(
              $db: $db,
              $table: $db.reminders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> notesRefs(
      Expression<bool> Function($$NotesTableFilterComposer f) f) {
    final $$NotesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.notes,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NotesTableFilterComposer(
              $db: $db,
              $table: $db.notes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> sharedContentsRefs(
      Expression<bool> Function($$SharedContentsTableFilterComposer f) f) {
    final $$SharedContentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sharedContents,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SharedContentsTableFilterComposer(
              $db: $db,
              $table: $db.sharedContents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> aiActionsLogsRefs(
      Expression<bool> Function($$AiActionsLogsTableFilterComposer f) f) {
    final $$AiActionsLogsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.aiActionsLogs,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AiActionsLogsTableFilterComposer(
              $db: $db,
              $table: $db.aiActionsLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> dailyLogsRefs(
      Expression<bool> Function($$DailyLogsTableFilterComposer f) f) {
    final $$DailyLogsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dailyLogs,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DailyLogsTableFilterComposer(
              $db: $db,
              $table: $db.dailyLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentTaskId => $composableBuilder(
      column: $table.parentTaskId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get estimatedHours => $composableBuilder(
      column: $table.estimatedHours,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurrenceType => $composableBuilder(
      column: $table.recurrenceType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurrenceDays => $composableBuilder(
      column: $table.recurrenceDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recurrenceStart => $composableBuilder(
      column: $table.recurrenceStart,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recurrenceEnd => $composableBuilder(
      column: $table.recurrenceEnd,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contact => $composableBuilder(
      column: $table.contact, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get voiceNotePath => $composableBuilder(
      column: $table.voiceNotePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aiRawTranscript => $composableBuilder(
      column: $table.aiRawTranscript,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get aiGenerated => $composableBuilder(
      column: $table.aiGenerated, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.workspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkspacesTableOrderingComposer(
              $db: $db,
              $table: $db.workspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkspaceSectionsTableOrderingComposer get sectionId {
    final $$WorkspaceSectionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sectionId,
        referencedTable: $db.workspaceSections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkspaceSectionsTableOrderingComposer(
              $db: $db,
              $table: $db.workspaceSections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get parentTaskId => $composableBuilder(
      column: $table.parentTaskId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<double> get estimatedHours => $composableBuilder(
      column: $table.estimatedHours, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => column);

  GeneratedColumn<String> get recurrenceType => $composableBuilder(
      column: $table.recurrenceType, builder: (column) => column);

  GeneratedColumn<String> get recurrenceDays => $composableBuilder(
      column: $table.recurrenceDays, builder: (column) => column);

  GeneratedColumn<int> get recurrenceStart => $composableBuilder(
      column: $table.recurrenceStart, builder: (column) => column);

  GeneratedColumn<int> get recurrenceEnd => $composableBuilder(
      column: $table.recurrenceEnd, builder: (column) => column);

  GeneratedColumn<String> get contact =>
      $composableBuilder(column: $table.contact, builder: (column) => column);

  GeneratedColumn<String> get voiceNotePath => $composableBuilder(
      column: $table.voiceNotePath, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get aiRawTranscript => $composableBuilder(
      column: $table.aiRawTranscript, builder: (column) => column);

  GeneratedColumn<bool> get aiGenerated => $composableBuilder(
      column: $table.aiGenerated, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.workspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkspacesTableAnnotationComposer(
              $db: $db,
              $table: $db.workspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkspaceSectionsTableAnnotationComposer get sectionId {
    final $$WorkspaceSectionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.sectionId,
            referencedTable: $db.workspaceSections,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$WorkspaceSectionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.workspaceSections,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  Expression<T> remindersRefs<T extends Object>(
      Expression<T> Function($$RemindersTableAnnotationComposer a) f) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reminders,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RemindersTableAnnotationComposer(
              $db: $db,
              $table: $db.reminders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> notesRefs<T extends Object>(
      Expression<T> Function($$NotesTableAnnotationComposer a) f) {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.notes,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NotesTableAnnotationComposer(
              $db: $db,
              $table: $db.notes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> sharedContentsRefs<T extends Object>(
      Expression<T> Function($$SharedContentsTableAnnotationComposer a) f) {
    final $$SharedContentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sharedContents,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SharedContentsTableAnnotationComposer(
              $db: $db,
              $table: $db.sharedContents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> aiActionsLogsRefs<T extends Object>(
      Expression<T> Function($$AiActionsLogsTableAnnotationComposer a) f) {
    final $$AiActionsLogsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.aiActionsLogs,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AiActionsLogsTableAnnotationComposer(
              $db: $db,
              $table: $db.aiActionsLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> dailyLogsRefs<T extends Object>(
      Expression<T> Function($$DailyLogsTableAnnotationComposer a) f) {
    final $$DailyLogsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dailyLogs,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DailyLogsTableAnnotationComposer(
              $db: $db,
              $table: $db.dailyLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, $$TasksTableReferences),
    Task,
    PrefetchHooks Function(
        {bool workspaceId,
        bool sectionId,
        bool remindersRefs,
        bool notesRefs,
        bool sharedContentsRefs,
        bool aiActionsLogsRefs,
        bool dailyLogsRefs})> {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> workspaceId = const Value.absent(),
            Value<String?> sectionId = const Value.absent(),
            Value<String?> parentTaskId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int?> deadline = const Value.absent(),
            Value<double?> estimatedHours = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<String?> recurrenceType = const Value.absent(),
            Value<String?> recurrenceDays = const Value.absent(),
            Value<int?> recurrenceStart = const Value.absent(),
            Value<int?> recurrenceEnd = const Value.absent(),
            Value<String?> contact = const Value.absent(),
            Value<String?> voiceNotePath = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String?> aiRawTranscript = const Value.absent(),
            Value<bool> aiGenerated = const Value.absent(),
            Value<int?> completedAt = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion(
            id: id,
            workspaceId: workspaceId,
            sectionId: sectionId,
            parentTaskId: parentTaskId,
            name: name,
            description: description,
            deadline: deadline,
            estimatedHours: estimatedHours,
            priority: priority,
            status: status,
            isRecurring: isRecurring,
            recurrenceType: recurrenceType,
            recurrenceDays: recurrenceDays,
            recurrenceStart: recurrenceStart,
            recurrenceEnd: recurrenceEnd,
            contact: contact,
            voiceNotePath: voiceNotePath,
            source: source,
            aiRawTranscript: aiRawTranscript,
            aiGenerated: aiGenerated,
            completedAt: completedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String workspaceId,
            Value<String?> sectionId = const Value.absent(),
            Value<String?> parentTaskId = const Value.absent(),
            required String name,
            Value<String?> description = const Value.absent(),
            Value<int?> deadline = const Value.absent(),
            Value<double?> estimatedHours = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<String?> recurrenceType = const Value.absent(),
            Value<String?> recurrenceDays = const Value.absent(),
            Value<int?> recurrenceStart = const Value.absent(),
            Value<int?> recurrenceEnd = const Value.absent(),
            Value<String?> contact = const Value.absent(),
            Value<String?> voiceNotePath = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String?> aiRawTranscript = const Value.absent(),
            Value<bool> aiGenerated = const Value.absent(),
            Value<int?> completedAt = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            id: id,
            workspaceId: workspaceId,
            sectionId: sectionId,
            parentTaskId: parentTaskId,
            name: name,
            description: description,
            deadline: deadline,
            estimatedHours: estimatedHours,
            priority: priority,
            status: status,
            isRecurring: isRecurring,
            recurrenceType: recurrenceType,
            recurrenceDays: recurrenceDays,
            recurrenceStart: recurrenceStart,
            recurrenceEnd: recurrenceEnd,
            contact: contact,
            voiceNotePath: voiceNotePath,
            source: source,
            aiRawTranscript: aiRawTranscript,
            aiGenerated: aiGenerated,
            completedAt: completedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TasksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {workspaceId = false,
              sectionId = false,
              remindersRefs = false,
              notesRefs = false,
              sharedContentsRefs = false,
              aiActionsLogsRefs = false,
              dailyLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (remindersRefs) db.reminders,
                if (notesRefs) db.notes,
                if (sharedContentsRefs) db.sharedContents,
                if (aiActionsLogsRefs) db.aiActionsLogs,
                if (dailyLogsRefs) db.dailyLogs
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (workspaceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workspaceId,
                    referencedTable:
                        $$TasksTableReferences._workspaceIdTable(db),
                    referencedColumn:
                        $$TasksTableReferences._workspaceIdTable(db).id,
                  ) as T;
                }
                if (sectionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sectionId,
                    referencedTable: $$TasksTableReferences._sectionIdTable(db),
                    referencedColumn:
                        $$TasksTableReferences._sectionIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (remindersRefs)
                    await $_getPrefetchedData<Task, $TasksTable, Reminder>(
                        currentTable: table,
                        referencedTable:
                            $$TasksTableReferences._remindersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TasksTableReferences(db, table, p0).remindersRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.taskId == item.id),
                        typedResults: items),
                  if (notesRefs)
                    await $_getPrefetchedData<Task, $TasksTable, Note>(
                        currentTable: table,
                        referencedTable:
                            $$TasksTableReferences._notesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TasksTableReferences(db, table, p0).notesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.taskId == item.id),
                        typedResults: items),
                  if (sharedContentsRefs)
                    await $_getPrefetchedData<Task, $TasksTable, SharedContent>(
                        currentTable: table,
                        referencedTable:
                            $$TasksTableReferences._sharedContentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TasksTableReferences(db, table, p0)
                                .sharedContentsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.taskId == item.id),
                        typedResults: items),
                  if (aiActionsLogsRefs)
                    await $_getPrefetchedData<Task, $TasksTable, AiActionsLog>(
                        currentTable: table,
                        referencedTable:
                            $$TasksTableReferences._aiActionsLogsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TasksTableReferences(db, table, p0)
                                .aiActionsLogsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.taskId == item.id),
                        typedResults: items),
                  if (dailyLogsRefs)
                    await $_getPrefetchedData<Task, $TasksTable, DailyLog>(
                        currentTable: table,
                        referencedTable:
                            $$TasksTableReferences._dailyLogsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TasksTableReferences(db, table, p0).dailyLogsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.taskId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, $$TasksTableReferences),
    Task,
    PrefetchHooks Function(
        {bool workspaceId,
        bool sectionId,
        bool remindersRefs,
        bool notesRefs,
        bool sharedContentsRefs,
        bool aiActionsLogsRefs,
        bool dailyLogsRefs})>;
typedef $$EventsTableCreateCompanionBuilder = EventsCompanion Function({
  required String id,
  required String workspaceId,
  Value<String?> sectionId,
  required String title,
  Value<String?> description,
  required int startAt,
  required int endAt,
  Value<String?> location,
  Value<bool> isRecurring,
  Value<String?> recurrenceRule,
  Value<String> priority,
  Value<String> status,
  Value<String> source,
  Value<String?> aiRawTranscript,
  Value<String?> externalCalId,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$EventsTableUpdateCompanionBuilder = EventsCompanion Function({
  Value<String> id,
  Value<String> workspaceId,
  Value<String?> sectionId,
  Value<String> title,
  Value<String?> description,
  Value<int> startAt,
  Value<int> endAt,
  Value<String?> location,
  Value<bool> isRecurring,
  Value<String?> recurrenceRule,
  Value<String> priority,
  Value<String> status,
  Value<String> source,
  Value<String?> aiRawTranscript,
  Value<String?> externalCalId,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});

final class $$EventsTableReferences
    extends BaseReferences<_$AppDatabase, $EventsTable, Event> {
  $$EventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.workspaces.createAlias(
          $_aliasNameGenerator(db.events.workspaceId, db.workspaces.id));

  $$WorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<String>('workspace_id')!;

    final manager = $$WorkspacesTableTableManager($_db, $_db.workspaces)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $WorkspaceSectionsTable _sectionIdTable(_$AppDatabase db) =>
      db.workspaceSections.createAlias(
          $_aliasNameGenerator(db.events.sectionId, db.workspaceSections.id));

  $$WorkspaceSectionsTableProcessedTableManager? get sectionId {
    final $_column = $_itemColumn<String>('section_id');
    if ($_column == null) return null;
    final manager =
        $$WorkspaceSectionsTableTableManager($_db, $_db.workspaceSections)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$RemindersTable, List<Reminder>>
      _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.reminders,
          aliasName: $_aliasNameGenerator(db.events.id, db.reminders.eventId));

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager($_db, $_db.reminders)
        .filter((f) => f.eventId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$NotesTable, List<Note>> _notesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.notes,
          aliasName: $_aliasNameGenerator(db.events.id, db.notes.eventId));

  $$NotesTableProcessedTableManager get notesRefs {
    final manager = $$NotesTableTableManager($_db, $_db.notes)
        .filter((f) => f.eventId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_notesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startAt => $composableBuilder(
      column: $table.startAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endAt => $composableBuilder(
      column: $table.endAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurrenceRule => $composableBuilder(
      column: $table.recurrenceRule,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aiRawTranscript => $composableBuilder(
      column: $table.aiRawTranscript,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get externalCalId => $composableBuilder(
      column: $table.externalCalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.workspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkspacesTableFilterComposer(
              $db: $db,
              $table: $db.workspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkspaceSectionsTableFilterComposer get sectionId {
    final $$WorkspaceSectionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sectionId,
        referencedTable: $db.workspaceSections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkspaceSectionsTableFilterComposer(
              $db: $db,
              $table: $db.workspaceSections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> remindersRefs(
      Expression<bool> Function($$RemindersTableFilterComposer f) f) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reminders,
        getReferencedColumn: (t) => t.eventId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RemindersTableFilterComposer(
              $db: $db,
              $table: $db.reminders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> notesRefs(
      Expression<bool> Function($$NotesTableFilterComposer f) f) {
    final $$NotesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.notes,
        getReferencedColumn: (t) => t.eventId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NotesTableFilterComposer(
              $db: $db,
              $table: $db.notes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startAt => $composableBuilder(
      column: $table.startAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endAt => $composableBuilder(
      column: $table.endAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurrenceRule => $composableBuilder(
      column: $table.recurrenceRule,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aiRawTranscript => $composableBuilder(
      column: $table.aiRawTranscript,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get externalCalId => $composableBuilder(
      column: $table.externalCalId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.workspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkspacesTableOrderingComposer(
              $db: $db,
              $table: $db.workspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkspaceSectionsTableOrderingComposer get sectionId {
    final $$WorkspaceSectionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sectionId,
        referencedTable: $db.workspaceSections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkspaceSectionsTableOrderingComposer(
              $db: $db,
              $table: $db.workspaceSections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<int> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => column);

  GeneratedColumn<String> get recurrenceRule => $composableBuilder(
      column: $table.recurrenceRule, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get aiRawTranscript => $composableBuilder(
      column: $table.aiRawTranscript, builder: (column) => column);

  GeneratedColumn<String> get externalCalId => $composableBuilder(
      column: $table.externalCalId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.workspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkspacesTableAnnotationComposer(
              $db: $db,
              $table: $db.workspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkspaceSectionsTableAnnotationComposer get sectionId {
    final $$WorkspaceSectionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.sectionId,
            referencedTable: $db.workspaceSections,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$WorkspaceSectionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.workspaceSections,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  Expression<T> remindersRefs<T extends Object>(
      Expression<T> Function($$RemindersTableAnnotationComposer a) f) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reminders,
        getReferencedColumn: (t) => t.eventId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RemindersTableAnnotationComposer(
              $db: $db,
              $table: $db.reminders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> notesRefs<T extends Object>(
      Expression<T> Function($$NotesTableAnnotationComposer a) f) {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.notes,
        getReferencedColumn: (t) => t.eventId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NotesTableAnnotationComposer(
              $db: $db,
              $table: $db.notes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$EventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EventsTable,
    Event,
    $$EventsTableFilterComposer,
    $$EventsTableOrderingComposer,
    $$EventsTableAnnotationComposer,
    $$EventsTableCreateCompanionBuilder,
    $$EventsTableUpdateCompanionBuilder,
    (Event, $$EventsTableReferences),
    Event,
    PrefetchHooks Function(
        {bool workspaceId,
        bool sectionId,
        bool remindersRefs,
        bool notesRefs})> {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> workspaceId = const Value.absent(),
            Value<String?> sectionId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> startAt = const Value.absent(),
            Value<int> endAt = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<String?> recurrenceRule = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String?> aiRawTranscript = const Value.absent(),
            Value<String?> externalCalId = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventsCompanion(
            id: id,
            workspaceId: workspaceId,
            sectionId: sectionId,
            title: title,
            description: description,
            startAt: startAt,
            endAt: endAt,
            location: location,
            isRecurring: isRecurring,
            recurrenceRule: recurrenceRule,
            priority: priority,
            status: status,
            source: source,
            aiRawTranscript: aiRawTranscript,
            externalCalId: externalCalId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String workspaceId,
            Value<String?> sectionId = const Value.absent(),
            required String title,
            Value<String?> description = const Value.absent(),
            required int startAt,
            required int endAt,
            Value<String?> location = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<String?> recurrenceRule = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String?> aiRawTranscript = const Value.absent(),
            Value<String?> externalCalId = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventsCompanion.insert(
            id: id,
            workspaceId: workspaceId,
            sectionId: sectionId,
            title: title,
            description: description,
            startAt: startAt,
            endAt: endAt,
            location: location,
            isRecurring: isRecurring,
            recurrenceRule: recurrenceRule,
            priority: priority,
            status: status,
            source: source,
            aiRawTranscript: aiRawTranscript,
            externalCalId: externalCalId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$EventsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {workspaceId = false,
              sectionId = false,
              remindersRefs = false,
              notesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (remindersRefs) db.reminders,
                if (notesRefs) db.notes
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (workspaceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workspaceId,
                    referencedTable:
                        $$EventsTableReferences._workspaceIdTable(db),
                    referencedColumn:
                        $$EventsTableReferences._workspaceIdTable(db).id,
                  ) as T;
                }
                if (sectionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sectionId,
                    referencedTable:
                        $$EventsTableReferences._sectionIdTable(db),
                    referencedColumn:
                        $$EventsTableReferences._sectionIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (remindersRefs)
                    await $_getPrefetchedData<Event, $EventsTable, Reminder>(
                        currentTable: table,
                        referencedTable:
                            $$EventsTableReferences._remindersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$EventsTableReferences(db, table, p0)
                                .remindersRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.eventId == item.id),
                        typedResults: items),
                  if (notesRefs)
                    await $_getPrefetchedData<Event, $EventsTable, Note>(
                        currentTable: table,
                        referencedTable:
                            $$EventsTableReferences._notesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$EventsTableReferences(db, table, p0).notesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.eventId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$EventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EventsTable,
    Event,
    $$EventsTableFilterComposer,
    $$EventsTableOrderingComposer,
    $$EventsTableAnnotationComposer,
    $$EventsTableCreateCompanionBuilder,
    $$EventsTableUpdateCompanionBuilder,
    (Event, $$EventsTableReferences),
    Event,
    PrefetchHooks Function(
        {bool workspaceId,
        bool sectionId,
        bool remindersRefs,
        bool notesRefs})>;
typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  required String id,
  Value<String?> taskId,
  Value<String?> eventId,
  required int fireAt,
  Value<String> type,
  Value<String> status,
  Value<int?> snoozedUntil,
  Value<bool> hasFired,
  Value<bool> missedDnd,
  Value<int?> replayedAt,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<String> id,
  Value<String?> taskId,
  Value<String?> eventId,
  Value<int> fireAt,
  Value<String> type,
  Value<String> status,
  Value<int?> snoozedUntil,
  Value<bool> hasFired,
  Value<bool> missedDnd,
  Value<int?> replayedAt,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $$RemindersTableReferences
    extends BaseReferences<_$AppDatabase, $RemindersTable, Reminder> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) => db.tasks
      .createAlias($_aliasNameGenerator(db.reminders.taskId, db.tasks.id));

  $$TasksTableProcessedTableManager? get taskId {
    final $_column = $_itemColumn<String>('task_id');
    if ($_column == null) return null;
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $EventsTable _eventIdTable(_$AppDatabase db) => db.events
      .createAlias($_aliasNameGenerator(db.reminders.eventId, db.events.id));

  $$EventsTableProcessedTableManager? get eventId {
    final $_column = $_itemColumn<String>('event_id');
    if ($_column == null) return null;
    final manager = $$EventsTableTableManager($_db, $_db.events)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$NotificationLogsTable, List<NotificationLog>>
      _notificationLogsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.notificationLogs,
              aliasName: $_aliasNameGenerator(
                  db.reminders.id, db.notificationLogs.reminderId));

  $$NotificationLogsTableProcessedTableManager get notificationLogsRefs {
    final manager = $$NotificationLogsTableTableManager(
            $_db, $_db.notificationLogs)
        .filter((f) => f.reminderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_notificationLogsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fireAt => $composableBuilder(
      column: $table.fireAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get snoozedUntil => $composableBuilder(
      column: $table.snoozedUntil, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasFired => $composableBuilder(
      column: $table.hasFired, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get missedDnd => $composableBuilder(
      column: $table.missedDnd, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get replayedAt => $composableBuilder(
      column: $table.replayedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$EventsTableFilterComposer get eventId {
    final $$EventsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.eventId,
        referencedTable: $db.events,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EventsTableFilterComposer(
              $db: $db,
              $table: $db.events,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> notificationLogsRefs(
      Expression<bool> Function($$NotificationLogsTableFilterComposer f) f) {
    final $$NotificationLogsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.notificationLogs,
        getReferencedColumn: (t) => t.reminderId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NotificationLogsTableFilterComposer(
              $db: $db,
              $table: $db.notificationLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fireAt => $composableBuilder(
      column: $table.fireAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get snoozedUntil => $composableBuilder(
      column: $table.snoozedUntil,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasFired => $composableBuilder(
      column: $table.hasFired, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get missedDnd => $composableBuilder(
      column: $table.missedDnd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get replayedAt => $composableBuilder(
      column: $table.replayedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$EventsTableOrderingComposer get eventId {
    final $$EventsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.eventId,
        referencedTable: $db.events,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EventsTableOrderingComposer(
              $db: $db,
              $table: $db.events,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get fireAt =>
      $composableBuilder(column: $table.fireAt, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get snoozedUntil => $composableBuilder(
      column: $table.snoozedUntil, builder: (column) => column);

  GeneratedColumn<bool> get hasFired =>
      $composableBuilder(column: $table.hasFired, builder: (column) => column);

  GeneratedColumn<bool> get missedDnd =>
      $composableBuilder(column: $table.missedDnd, builder: (column) => column);

  GeneratedColumn<int> get replayedAt => $composableBuilder(
      column: $table.replayedAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$EventsTableAnnotationComposer get eventId {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.eventId,
        referencedTable: $db.events,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EventsTableAnnotationComposer(
              $db: $db,
              $table: $db.events,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> notificationLogsRefs<T extends Object>(
      Expression<T> Function($$NotificationLogsTableAnnotationComposer a) f) {
    final $$NotificationLogsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.notificationLogs,
        getReferencedColumn: (t) => t.reminderId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NotificationLogsTableAnnotationComposer(
              $db: $db,
              $table: $db.notificationLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RemindersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RemindersTable,
    Reminder,
    $$RemindersTableFilterComposer,
    $$RemindersTableOrderingComposer,
    $$RemindersTableAnnotationComposer,
    $$RemindersTableCreateCompanionBuilder,
    $$RemindersTableUpdateCompanionBuilder,
    (Reminder, $$RemindersTableReferences),
    Reminder,
    PrefetchHooks Function(
        {bool taskId, bool eventId, bool notificationLogsRefs})> {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> taskId = const Value.absent(),
            Value<String?> eventId = const Value.absent(),
            Value<int> fireAt = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int?> snoozedUntil = const Value.absent(),
            Value<bool> hasFired = const Value.absent(),
            Value<bool> missedDnd = const Value.absent(),
            Value<int?> replayedAt = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RemindersCompanion(
            id: id,
            taskId: taskId,
            eventId: eventId,
            fireAt: fireAt,
            type: type,
            status: status,
            snoozedUntil: snoozedUntil,
            hasFired: hasFired,
            missedDnd: missedDnd,
            replayedAt: replayedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> taskId = const Value.absent(),
            Value<String?> eventId = const Value.absent(),
            required int fireAt,
            Value<String> type = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int?> snoozedUntil = const Value.absent(),
            Value<bool> hasFired = const Value.absent(),
            Value<bool> missedDnd = const Value.absent(),
            Value<int?> replayedAt = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              RemindersCompanion.insert(
            id: id,
            taskId: taskId,
            eventId: eventId,
            fireAt: fireAt,
            type: type,
            status: status,
            snoozedUntil: snoozedUntil,
            hasFired: hasFired,
            missedDnd: missedDnd,
            replayedAt: replayedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RemindersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {taskId = false, eventId = false, notificationLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (notificationLogsRefs) db.notificationLogs
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (taskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.taskId,
                    referencedTable:
                        $$RemindersTableReferences._taskIdTable(db),
                    referencedColumn:
                        $$RemindersTableReferences._taskIdTable(db).id,
                  ) as T;
                }
                if (eventId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.eventId,
                    referencedTable:
                        $$RemindersTableReferences._eventIdTable(db),
                    referencedColumn:
                        $$RemindersTableReferences._eventIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (notificationLogsRefs)
                    await $_getPrefetchedData<Reminder, $RemindersTable,
                            NotificationLog>(
                        currentTable: table,
                        referencedTable: $$RemindersTableReferences
                            ._notificationLogsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RemindersTableReferences(db, table, p0)
                                .notificationLogsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.reminderId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RemindersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RemindersTable,
    Reminder,
    $$RemindersTableFilterComposer,
    $$RemindersTableOrderingComposer,
    $$RemindersTableAnnotationComposer,
    $$RemindersTableCreateCompanionBuilder,
    $$RemindersTableUpdateCompanionBuilder,
    (Reminder, $$RemindersTableReferences),
    Reminder,
    PrefetchHooks Function(
        {bool taskId, bool eventId, bool notificationLogsRefs})>;
typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  required String id,
  Value<String?> taskId,
  Value<String?> eventId,
  required String workspaceId,
  required String content,
  Value<String> type,
  Value<String?> filePath,
  Value<String?> url,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<String> id,
  Value<String?> taskId,
  Value<String?> eventId,
  Value<String> workspaceId,
  Value<String> content,
  Value<String> type,
  Value<String?> filePath,
  Value<String?> url,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});

final class $$NotesTableReferences
    extends BaseReferences<_$AppDatabase, $NotesTable, Note> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias($_aliasNameGenerator(db.notes.taskId, db.tasks.id));

  $$TasksTableProcessedTableManager? get taskId {
    final $_column = $_itemColumn<String>('task_id');
    if ($_column == null) return null;
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $EventsTable _eventIdTable(_$AppDatabase db) => db.events
      .createAlias($_aliasNameGenerator(db.notes.eventId, db.events.id));

  $$EventsTableProcessedTableManager? get eventId {
    final $_column = $_itemColumn<String>('event_id');
    if ($_column == null) return null;
    final manager = $$EventsTableTableManager($_db, $_db.events)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.workspaces.createAlias(
          $_aliasNameGenerator(db.notes.workspaceId, db.workspaces.id));

  $$WorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<String>('workspace_id')!;

    final manager = $$WorkspacesTableTableManager($_db, $_db.workspaces)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$EventsTableFilterComposer get eventId {
    final $$EventsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.eventId,
        referencedTable: $db.events,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EventsTableFilterComposer(
              $db: $db,
              $table: $db.events,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.workspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkspacesTableFilterComposer(
              $db: $db,
              $table: $db.workspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$EventsTableOrderingComposer get eventId {
    final $$EventsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.eventId,
        referencedTable: $db.events,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EventsTableOrderingComposer(
              $db: $db,
              $table: $db.events,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.workspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkspacesTableOrderingComposer(
              $db: $db,
              $table: $db.workspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$EventsTableAnnotationComposer get eventId {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.eventId,
        referencedTable: $db.events,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EventsTableAnnotationComposer(
              $db: $db,
              $table: $db.events,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.workspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkspacesTableAnnotationComposer(
              $db: $db,
              $table: $db.workspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$NotesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotesTable,
    Note,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableAnnotationComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder,
    (Note, $$NotesTableReferences),
    Note,
    PrefetchHooks Function({bool taskId, bool eventId, bool workspaceId})> {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> taskId = const Value.absent(),
            Value<String?> eventId = const Value.absent(),
            Value<String> workspaceId = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> filePath = const Value.absent(),
            Value<String?> url = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotesCompanion(
            id: id,
            taskId: taskId,
            eventId: eventId,
            workspaceId: workspaceId,
            content: content,
            type: type,
            filePath: filePath,
            url: url,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> taskId = const Value.absent(),
            Value<String?> eventId = const Value.absent(),
            required String workspaceId,
            required String content,
            Value<String> type = const Value.absent(),
            Value<String?> filePath = const Value.absent(),
            Value<String?> url = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotesCompanion.insert(
            id: id,
            taskId: taskId,
            eventId: eventId,
            workspaceId: workspaceId,
            content: content,
            type: type,
            filePath: filePath,
            url: url,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$NotesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {taskId = false, eventId = false, workspaceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (taskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.taskId,
                    referencedTable: $$NotesTableReferences._taskIdTable(db),
                    referencedColumn:
                        $$NotesTableReferences._taskIdTable(db).id,
                  ) as T;
                }
                if (eventId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.eventId,
                    referencedTable: $$NotesTableReferences._eventIdTable(db),
                    referencedColumn:
                        $$NotesTableReferences._eventIdTable(db).id,
                  ) as T;
                }
                if (workspaceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workspaceId,
                    referencedTable:
                        $$NotesTableReferences._workspaceIdTable(db),
                    referencedColumn:
                        $$NotesTableReferences._workspaceIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$NotesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NotesTable,
    Note,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableAnnotationComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder,
    (Note, $$NotesTableReferences),
    Note,
    PrefetchHooks Function({bool taskId, bool eventId, bool workspaceId})>;
typedef $$SharedContentsTableCreateCompanionBuilder = SharedContentsCompanion
    Function({
  required String id,
  required String type,
  Value<String?> rawPath,
  Value<String?> rawUrl,
  Value<String?> ocrText,
  Value<String?> aiSummary,
  Value<String?> pageTitle,
  Value<String> status,
  Value<String?> workspaceId,
  Value<String?> taskId,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$SharedContentsTableUpdateCompanionBuilder = SharedContentsCompanion
    Function({
  Value<String> id,
  Value<String> type,
  Value<String?> rawPath,
  Value<String?> rawUrl,
  Value<String?> ocrText,
  Value<String?> aiSummary,
  Value<String?> pageTitle,
  Value<String> status,
  Value<String?> workspaceId,
  Value<String?> taskId,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $$SharedContentsTableReferences
    extends BaseReferences<_$AppDatabase, $SharedContentsTable, SharedContent> {
  $$SharedContentsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.workspaces.createAlias($_aliasNameGenerator(
          db.sharedContents.workspaceId, db.workspaces.id));

  $$WorkspacesTableProcessedTableManager? get workspaceId {
    final $_column = $_itemColumn<String>('workspace_id');
    if ($_column == null) return null;
    final manager = $$WorkspacesTableTableManager($_db, $_db.workspaces)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TasksTable _taskIdTable(_$AppDatabase db) => db.tasks
      .createAlias($_aliasNameGenerator(db.sharedContents.taskId, db.tasks.id));

  $$TasksTableProcessedTableManager? get taskId {
    final $_column = $_itemColumn<String>('task_id');
    if ($_column == null) return null;
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SharedContentsTableFilterComposer
    extends Composer<_$AppDatabase, $SharedContentsTable> {
  $$SharedContentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawPath => $composableBuilder(
      column: $table.rawPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawUrl => $composableBuilder(
      column: $table.rawUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ocrText => $composableBuilder(
      column: $table.ocrText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aiSummary => $composableBuilder(
      column: $table.aiSummary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pageTitle => $composableBuilder(
      column: $table.pageTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.workspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkspacesTableFilterComposer(
              $db: $db,
              $table: $db.workspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SharedContentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SharedContentsTable> {
  $$SharedContentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawPath => $composableBuilder(
      column: $table.rawPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawUrl => $composableBuilder(
      column: $table.rawUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ocrText => $composableBuilder(
      column: $table.ocrText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aiSummary => $composableBuilder(
      column: $table.aiSummary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pageTitle => $composableBuilder(
      column: $table.pageTitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.workspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkspacesTableOrderingComposer(
              $db: $db,
              $table: $db.workspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SharedContentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SharedContentsTable> {
  $$SharedContentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get rawPath =>
      $composableBuilder(column: $table.rawPath, builder: (column) => column);

  GeneratedColumn<String> get rawUrl =>
      $composableBuilder(column: $table.rawUrl, builder: (column) => column);

  GeneratedColumn<String> get ocrText =>
      $composableBuilder(column: $table.ocrText, builder: (column) => column);

  GeneratedColumn<String> get aiSummary =>
      $composableBuilder(column: $table.aiSummary, builder: (column) => column);

  GeneratedColumn<String> get pageTitle =>
      $composableBuilder(column: $table.pageTitle, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workspaceId,
        referencedTable: $db.workspaces,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkspacesTableAnnotationComposer(
              $db: $db,
              $table: $db.workspaces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SharedContentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SharedContentsTable,
    SharedContent,
    $$SharedContentsTableFilterComposer,
    $$SharedContentsTableOrderingComposer,
    $$SharedContentsTableAnnotationComposer,
    $$SharedContentsTableCreateCompanionBuilder,
    $$SharedContentsTableUpdateCompanionBuilder,
    (SharedContent, $$SharedContentsTableReferences),
    SharedContent,
    PrefetchHooks Function({bool workspaceId, bool taskId})> {
  $$SharedContentsTableTableManager(
      _$AppDatabase db, $SharedContentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SharedContentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SharedContentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SharedContentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> rawPath = const Value.absent(),
            Value<String?> rawUrl = const Value.absent(),
            Value<String?> ocrText = const Value.absent(),
            Value<String?> aiSummary = const Value.absent(),
            Value<String?> pageTitle = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> workspaceId = const Value.absent(),
            Value<String?> taskId = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SharedContentsCompanion(
            id: id,
            type: type,
            rawPath: rawPath,
            rawUrl: rawUrl,
            ocrText: ocrText,
            aiSummary: aiSummary,
            pageTitle: pageTitle,
            status: status,
            workspaceId: workspaceId,
            taskId: taskId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            Value<String?> rawPath = const Value.absent(),
            Value<String?> rawUrl = const Value.absent(),
            Value<String?> ocrText = const Value.absent(),
            Value<String?> aiSummary = const Value.absent(),
            Value<String?> pageTitle = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> workspaceId = const Value.absent(),
            Value<String?> taskId = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SharedContentsCompanion.insert(
            id: id,
            type: type,
            rawPath: rawPath,
            rawUrl: rawUrl,
            ocrText: ocrText,
            aiSummary: aiSummary,
            pageTitle: pageTitle,
            status: status,
            workspaceId: workspaceId,
            taskId: taskId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SharedContentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({workspaceId = false, taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (workspaceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workspaceId,
                    referencedTable:
                        $$SharedContentsTableReferences._workspaceIdTable(db),
                    referencedColumn: $$SharedContentsTableReferences
                        ._workspaceIdTable(db)
                        .id,
                  ) as T;
                }
                if (taskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.taskId,
                    referencedTable:
                        $$SharedContentsTableReferences._taskIdTable(db),
                    referencedColumn:
                        $$SharedContentsTableReferences._taskIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SharedContentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SharedContentsTable,
    SharedContent,
    $$SharedContentsTableFilterComposer,
    $$SharedContentsTableOrderingComposer,
    $$SharedContentsTableAnnotationComposer,
    $$SharedContentsTableCreateCompanionBuilder,
    $$SharedContentsTableUpdateCompanionBuilder,
    (SharedContent, $$SharedContentsTableReferences),
    SharedContent,
    PrefetchHooks Function({bool workspaceId, bool taskId})>;
typedef $$NotificationLogsTableCreateCompanionBuilder
    = NotificationLogsCompanion Function({
  required String id,
  required String reminderId,
  required int scheduledAt,
  Value<int?> firedAt,
  Value<bool> wasDnd,
  Value<int?> replayedAt,
  Value<bool> userDismissed,
  required int createdAt,
  Value<int> rowid,
});
typedef $$NotificationLogsTableUpdateCompanionBuilder
    = NotificationLogsCompanion Function({
  Value<String> id,
  Value<String> reminderId,
  Value<int> scheduledAt,
  Value<int?> firedAt,
  Value<bool> wasDnd,
  Value<int?> replayedAt,
  Value<bool> userDismissed,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $$NotificationLogsTableReferences extends BaseReferences<
    _$AppDatabase, $NotificationLogsTable, NotificationLog> {
  $$NotificationLogsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $RemindersTable _reminderIdTable(_$AppDatabase db) =>
      db.reminders.createAlias($_aliasNameGenerator(
          db.notificationLogs.reminderId, db.reminders.id));

  $$RemindersTableProcessedTableManager get reminderId {
    final $_column = $_itemColumn<String>('reminder_id')!;

    final manager = $$RemindersTableTableManager($_db, $_db.reminders)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reminderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$NotificationLogsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationLogsTable> {
  $$NotificationLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get firedAt => $composableBuilder(
      column: $table.firedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get wasDnd => $composableBuilder(
      column: $table.wasDnd, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get replayedAt => $composableBuilder(
      column: $table.replayedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get userDismissed => $composableBuilder(
      column: $table.userDismissed, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$RemindersTableFilterComposer get reminderId {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reminderId,
        referencedTable: $db.reminders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RemindersTableFilterComposer(
              $db: $db,
              $table: $db.reminders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$NotificationLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationLogsTable> {
  $$NotificationLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get firedAt => $composableBuilder(
      column: $table.firedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get wasDnd => $composableBuilder(
      column: $table.wasDnd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get replayedAt => $composableBuilder(
      column: $table.replayedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get userDismissed => $composableBuilder(
      column: $table.userDismissed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$RemindersTableOrderingComposer get reminderId {
    final $$RemindersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reminderId,
        referencedTable: $db.reminders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RemindersTableOrderingComposer(
              $db: $db,
              $table: $db.reminders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$NotificationLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationLogsTable> {
  $$NotificationLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => column);

  GeneratedColumn<int> get firedAt =>
      $composableBuilder(column: $table.firedAt, builder: (column) => column);

  GeneratedColumn<bool> get wasDnd =>
      $composableBuilder(column: $table.wasDnd, builder: (column) => column);

  GeneratedColumn<int> get replayedAt => $composableBuilder(
      column: $table.replayedAt, builder: (column) => column);

  GeneratedColumn<bool> get userDismissed => $composableBuilder(
      column: $table.userDismissed, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$RemindersTableAnnotationComposer get reminderId {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.reminderId,
        referencedTable: $db.reminders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RemindersTableAnnotationComposer(
              $db: $db,
              $table: $db.reminders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$NotificationLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotificationLogsTable,
    NotificationLog,
    $$NotificationLogsTableFilterComposer,
    $$NotificationLogsTableOrderingComposer,
    $$NotificationLogsTableAnnotationComposer,
    $$NotificationLogsTableCreateCompanionBuilder,
    $$NotificationLogsTableUpdateCompanionBuilder,
    (NotificationLog, $$NotificationLogsTableReferences),
    NotificationLog,
    PrefetchHooks Function({bool reminderId})> {
  $$NotificationLogsTableTableManager(
      _$AppDatabase db, $NotificationLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> reminderId = const Value.absent(),
            Value<int> scheduledAt = const Value.absent(),
            Value<int?> firedAt = const Value.absent(),
            Value<bool> wasDnd = const Value.absent(),
            Value<int?> replayedAt = const Value.absent(),
            Value<bool> userDismissed = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotificationLogsCompanion(
            id: id,
            reminderId: reminderId,
            scheduledAt: scheduledAt,
            firedAt: firedAt,
            wasDnd: wasDnd,
            replayedAt: replayedAt,
            userDismissed: userDismissed,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String reminderId,
            required int scheduledAt,
            Value<int?> firedAt = const Value.absent(),
            Value<bool> wasDnd = const Value.absent(),
            Value<int?> replayedAt = const Value.absent(),
            Value<bool> userDismissed = const Value.absent(),
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              NotificationLogsCompanion.insert(
            id: id,
            reminderId: reminderId,
            scheduledAt: scheduledAt,
            firedAt: firedAt,
            wasDnd: wasDnd,
            replayedAt: replayedAt,
            userDismissed: userDismissed,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$NotificationLogsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({reminderId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (reminderId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.reminderId,
                    referencedTable:
                        $$NotificationLogsTableReferences._reminderIdTable(db),
                    referencedColumn: $$NotificationLogsTableReferences
                        ._reminderIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$NotificationLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NotificationLogsTable,
    NotificationLog,
    $$NotificationLogsTableFilterComposer,
    $$NotificationLogsTableOrderingComposer,
    $$NotificationLogsTableAnnotationComposer,
    $$NotificationLogsTableCreateCompanionBuilder,
    $$NotificationLogsTableUpdateCompanionBuilder,
    (NotificationLog, $$NotificationLogsTableReferences),
    NotificationLog,
    PrefetchHooks Function({bool reminderId})>;
typedef $$AiActionsLogsTableCreateCompanionBuilder = AiActionsLogsCompanion
    Function({
  required String id,
  required String inputText,
  required String rawResponse,
  required String parsedJson,
  Value<double?> confidence,
  required String actionTaken,
  Value<String?> taskId,
  Value<bool> userEdited,
  required int createdAt,
  Value<int> rowid,
});
typedef $$AiActionsLogsTableUpdateCompanionBuilder = AiActionsLogsCompanion
    Function({
  Value<String> id,
  Value<String> inputText,
  Value<String> rawResponse,
  Value<String> parsedJson,
  Value<double?> confidence,
  Value<String> actionTaken,
  Value<String?> taskId,
  Value<bool> userEdited,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $$AiActionsLogsTableReferences
    extends BaseReferences<_$AppDatabase, $AiActionsLogsTable, AiActionsLog> {
  $$AiActionsLogsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) => db.tasks
      .createAlias($_aliasNameGenerator(db.aiActionsLogs.taskId, db.tasks.id));

  $$TasksTableProcessedTableManager? get taskId {
    final $_column = $_itemColumn<String>('task_id');
    if ($_column == null) return null;
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AiActionsLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AiActionsLogsTable> {
  $$AiActionsLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get inputText => $composableBuilder(
      column: $table.inputText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawResponse => $composableBuilder(
      column: $table.rawResponse, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parsedJson => $composableBuilder(
      column: $table.parsedJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionTaken => $composableBuilder(
      column: $table.actionTaken, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get userEdited => $composableBuilder(
      column: $table.userEdited, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AiActionsLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiActionsLogsTable> {
  $$AiActionsLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get inputText => $composableBuilder(
      column: $table.inputText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawResponse => $composableBuilder(
      column: $table.rawResponse, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parsedJson => $composableBuilder(
      column: $table.parsedJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionTaken => $composableBuilder(
      column: $table.actionTaken, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get userEdited => $composableBuilder(
      column: $table.userEdited, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AiActionsLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiActionsLogsTable> {
  $$AiActionsLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get inputText =>
      $composableBuilder(column: $table.inputText, builder: (column) => column);

  GeneratedColumn<String> get rawResponse => $composableBuilder(
      column: $table.rawResponse, builder: (column) => column);

  GeneratedColumn<String> get parsedJson => $composableBuilder(
      column: $table.parsedJson, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<String> get actionTaken => $composableBuilder(
      column: $table.actionTaken, builder: (column) => column);

  GeneratedColumn<bool> get userEdited => $composableBuilder(
      column: $table.userEdited, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AiActionsLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AiActionsLogsTable,
    AiActionsLog,
    $$AiActionsLogsTableFilterComposer,
    $$AiActionsLogsTableOrderingComposer,
    $$AiActionsLogsTableAnnotationComposer,
    $$AiActionsLogsTableCreateCompanionBuilder,
    $$AiActionsLogsTableUpdateCompanionBuilder,
    (AiActionsLog, $$AiActionsLogsTableReferences),
    AiActionsLog,
    PrefetchHooks Function({bool taskId})> {
  $$AiActionsLogsTableTableManager(_$AppDatabase db, $AiActionsLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiActionsLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiActionsLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiActionsLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> inputText = const Value.absent(),
            Value<String> rawResponse = const Value.absent(),
            Value<String> parsedJson = const Value.absent(),
            Value<double?> confidence = const Value.absent(),
            Value<String> actionTaken = const Value.absent(),
            Value<String?> taskId = const Value.absent(),
            Value<bool> userEdited = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AiActionsLogsCompanion(
            id: id,
            inputText: inputText,
            rawResponse: rawResponse,
            parsedJson: parsedJson,
            confidence: confidence,
            actionTaken: actionTaken,
            taskId: taskId,
            userEdited: userEdited,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String inputText,
            required String rawResponse,
            required String parsedJson,
            Value<double?> confidence = const Value.absent(),
            required String actionTaken,
            Value<String?> taskId = const Value.absent(),
            Value<bool> userEdited = const Value.absent(),
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AiActionsLogsCompanion.insert(
            id: id,
            inputText: inputText,
            rawResponse: rawResponse,
            parsedJson: parsedJson,
            confidence: confidence,
            actionTaken: actionTaken,
            taskId: taskId,
            userEdited: userEdited,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AiActionsLogsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (taskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.taskId,
                    referencedTable:
                        $$AiActionsLogsTableReferences._taskIdTable(db),
                    referencedColumn:
                        $$AiActionsLogsTableReferences._taskIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AiActionsLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AiActionsLogsTable,
    AiActionsLog,
    $$AiActionsLogsTableFilterComposer,
    $$AiActionsLogsTableOrderingComposer,
    $$AiActionsLogsTableAnnotationComposer,
    $$AiActionsLogsTableCreateCompanionBuilder,
    $$AiActionsLogsTableUpdateCompanionBuilder,
    (AiActionsLog, $$AiActionsLogsTableReferences),
    AiActionsLog,
    PrefetchHooks Function({bool taskId})>;
typedef $$OfflineQueuesTableCreateCompanionBuilder = OfflineQueuesCompanion
    Function({
  required String id,
  Value<String> type,
  required String content,
  Value<String?> contextJson,
  Value<String> status,
  Value<int> attempts,
  required int createdAt,
  Value<int?> processedAt,
  Value<int> rowid,
});
typedef $$OfflineQueuesTableUpdateCompanionBuilder = OfflineQueuesCompanion
    Function({
  Value<String> id,
  Value<String> type,
  Value<String> content,
  Value<String?> contextJson,
  Value<String> status,
  Value<int> attempts,
  Value<int> createdAt,
  Value<int?> processedAt,
  Value<int> rowid,
});

class $$OfflineQueuesTableFilterComposer
    extends Composer<_$AppDatabase, $OfflineQueuesTable> {
  $$OfflineQueuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contextJson => $composableBuilder(
      column: $table.contextJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get processedAt => $composableBuilder(
      column: $table.processedAt, builder: (column) => ColumnFilters(column));
}

class $$OfflineQueuesTableOrderingComposer
    extends Composer<_$AppDatabase, $OfflineQueuesTable> {
  $$OfflineQueuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contextJson => $composableBuilder(
      column: $table.contextJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get processedAt => $composableBuilder(
      column: $table.processedAt, builder: (column) => ColumnOrderings(column));
}

class $$OfflineQueuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OfflineQueuesTable> {
  $$OfflineQueuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get contextJson => $composableBuilder(
      column: $table.contextJson, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get processedAt => $composableBuilder(
      column: $table.processedAt, builder: (column) => column);
}

class $$OfflineQueuesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OfflineQueuesTable,
    OfflineQueue,
    $$OfflineQueuesTableFilterComposer,
    $$OfflineQueuesTableOrderingComposer,
    $$OfflineQueuesTableAnnotationComposer,
    $$OfflineQueuesTableCreateCompanionBuilder,
    $$OfflineQueuesTableUpdateCompanionBuilder,
    (
      OfflineQueue,
      BaseReferences<_$AppDatabase, $OfflineQueuesTable, OfflineQueue>
    ),
    OfflineQueue,
    PrefetchHooks Function()> {
  $$OfflineQueuesTableTableManager(_$AppDatabase db, $OfflineQueuesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineQueuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineQueuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflineQueuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String?> contextJson = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int?> processedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineQueuesCompanion(
            id: id,
            type: type,
            content: content,
            contextJson: contextJson,
            status: status,
            attempts: attempts,
            createdAt: createdAt,
            processedAt: processedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> type = const Value.absent(),
            required String content,
            Value<String?> contextJson = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            required int createdAt,
            Value<int?> processedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineQueuesCompanion.insert(
            id: id,
            type: type,
            content: content,
            contextJson: contextJson,
            status: status,
            attempts: attempts,
            createdAt: createdAt,
            processedAt: processedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OfflineQueuesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OfflineQueuesTable,
    OfflineQueue,
    $$OfflineQueuesTableFilterComposer,
    $$OfflineQueuesTableOrderingComposer,
    $$OfflineQueuesTableAnnotationComposer,
    $$OfflineQueuesTableCreateCompanionBuilder,
    $$OfflineQueuesTableUpdateCompanionBuilder,
    (
      OfflineQueue,
      BaseReferences<_$AppDatabase, $OfflineQueuesTable, OfflineQueue>
    ),
    OfflineQueue,
    PrefetchHooks Function()>;
typedef $$DailyLogsTableCreateCompanionBuilder = DailyLogsCompanion Function({
  required String id,
  required String taskId,
  required int logDate,
  required String status,
  Value<int?> doneAt,
  required int createdAt,
  Value<int> rowid,
});
typedef $$DailyLogsTableUpdateCompanionBuilder = DailyLogsCompanion Function({
  Value<String> id,
  Value<String> taskId,
  Value<int> logDate,
  Value<String> status,
  Value<int?> doneAt,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $$DailyLogsTableReferences
    extends BaseReferences<_$AppDatabase, $DailyLogsTable, DailyLog> {
  $$DailyLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) => db.tasks
      .createAlias($_aliasNameGenerator(db.dailyLogs.taskId, db.tasks.id));

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DailyLogsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyLogsTable> {
  $$DailyLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get logDate => $composableBuilder(
      column: $table.logDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get doneAt => $composableBuilder(
      column: $table.doneAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DailyLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyLogsTable> {
  $$DailyLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get logDate => $composableBuilder(
      column: $table.logDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get doneAt => $composableBuilder(
      column: $table.doneAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DailyLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyLogsTable> {
  $$DailyLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get logDate =>
      $composableBuilder(column: $table.logDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get doneAt =>
      $composableBuilder(column: $table.doneAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DailyLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailyLogsTable,
    DailyLog,
    $$DailyLogsTableFilterComposer,
    $$DailyLogsTableOrderingComposer,
    $$DailyLogsTableAnnotationComposer,
    $$DailyLogsTableCreateCompanionBuilder,
    $$DailyLogsTableUpdateCompanionBuilder,
    (DailyLog, $$DailyLogsTableReferences),
    DailyLog,
    PrefetchHooks Function({bool taskId})> {
  $$DailyLogsTableTableManager(_$AppDatabase db, $DailyLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> taskId = const Value.absent(),
            Value<int> logDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int?> doneAt = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyLogsCompanion(
            id: id,
            taskId: taskId,
            logDate: logDate,
            status: status,
            doneAt: doneAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String taskId,
            required int logDate,
            required String status,
            Value<int?> doneAt = const Value.absent(),
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyLogsCompanion.insert(
            id: id,
            taskId: taskId,
            logDate: logDate,
            status: status,
            doneAt: doneAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DailyLogsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (taskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.taskId,
                    referencedTable:
                        $$DailyLogsTableReferences._taskIdTable(db),
                    referencedColumn:
                        $$DailyLogsTableReferences._taskIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DailyLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DailyLogsTable,
    DailyLog,
    $$DailyLogsTableFilterComposer,
    $$DailyLogsTableOrderingComposer,
    $$DailyLogsTableAnnotationComposer,
    $$DailyLogsTableCreateCompanionBuilder,
    $$DailyLogsTableUpdateCompanionBuilder,
    (DailyLog, $$DailyLogsTableReferences),
    DailyLog,
    PrefetchHooks Function({bool taskId})>;
typedef $$SyncQueuesTableCreateCompanionBuilder = SyncQueuesCompanion Function({
  required String id,
  required String entityType,
  required String entityId,
  required String operation,
  required String payload,
  Value<String> status,
  Value<int> attempts,
  required int createdAt,
  Value<int?> syncedAt,
  Value<int> rowid,
});
typedef $$SyncQueuesTableUpdateCompanionBuilder = SyncQueuesCompanion Function({
  Value<String> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> operation,
  Value<String> payload,
  Value<String> status,
  Value<int> attempts,
  Value<int> createdAt,
  Value<int?> syncedAt,
  Value<int> rowid,
});

class $$SyncQueuesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueuesTable> {
  $$SyncQueuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));
}

class $$SyncQueuesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueuesTable> {
  $$SyncQueuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueuesTable> {
  $$SyncQueuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$SyncQueuesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueuesTable,
    SyncQueue,
    $$SyncQueuesTableFilterComposer,
    $$SyncQueuesTableOrderingComposer,
    $$SyncQueuesTableAnnotationComposer,
    $$SyncQueuesTableCreateCompanionBuilder,
    $$SyncQueuesTableUpdateCompanionBuilder,
    (SyncQueue, BaseReferences<_$AppDatabase, $SyncQueuesTable, SyncQueue>),
    SyncQueue,
    PrefetchHooks Function()> {
  $$SyncQueuesTableTableManager(_$AppDatabase db, $SyncQueuesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int?> syncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueuesCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payload: payload,
            status: status,
            attempts: attempts,
            createdAt: createdAt,
            syncedAt: syncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entityType,
            required String entityId,
            required String operation,
            required String payload,
            Value<String> status = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            required int createdAt,
            Value<int?> syncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueuesCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payload: payload,
            status: status,
            attempts: attempts,
            createdAt: createdAt,
            syncedAt: syncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueuesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueuesTable,
    SyncQueue,
    $$SyncQueuesTableFilterComposer,
    $$SyncQueuesTableOrderingComposer,
    $$SyncQueuesTableAnnotationComposer,
    $$SyncQueuesTableCreateCompanionBuilder,
    $$SyncQueuesTableUpdateCompanionBuilder,
    (SyncQueue, BaseReferences<_$AppDatabase, $SyncQueuesTable, SyncQueue>),
    SyncQueue,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WorkspacesTableTableManager get workspaces =>
      $$WorkspacesTableTableManager(_db, _db.workspaces);
  $$WorkspaceSectionsTableTableManager get workspaceSections =>
      $$WorkspaceSectionsTableTableManager(_db, _db.workspaceSections);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$SharedContentsTableTableManager get sharedContents =>
      $$SharedContentsTableTableManager(_db, _db.sharedContents);
  $$NotificationLogsTableTableManager get notificationLogs =>
      $$NotificationLogsTableTableManager(_db, _db.notificationLogs);
  $$AiActionsLogsTableTableManager get aiActionsLogs =>
      $$AiActionsLogsTableTableManager(_db, _db.aiActionsLogs);
  $$OfflineQueuesTableTableManager get offlineQueues =>
      $$OfflineQueuesTableTableManager(_db, _db.offlineQueues);
  $$DailyLogsTableTableManager get dailyLogs =>
      $$DailyLogsTableTableManager(_db, _db.dailyLogs);
  $$SyncQueuesTableTableManager get syncQueues =>
      $$SyncQueuesTableTableManager(_db, _db.syncQueues);
}
