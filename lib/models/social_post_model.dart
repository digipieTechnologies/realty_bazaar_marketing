import 'package:equatable/equatable.dart';
import 'broker_model.dart';
import 'media_model.dart';
import 'social_enums.dart';

class SocialPostModel extends Equatable {
  static const String tableName = "social_posts";

  final String? id;
  final BrokerModel? brokerId;
  final String? propertyId;
  final SocialPlatform? platform;
  final String? pageId;
  final String? postId;
  final String? caption;
  final List<MediaModel>? mediaUrls;
  final String? permalink;
  final int? viewsCount;
  final int? commentCount;
  final int? likesCount;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SocialPostModel({
    this.id,
    this.brokerId,
    this.propertyId,
    this.platform,
    this.pageId,
    this.postId,
    this.caption,
    this.mediaUrls,
    this.permalink,
    this.viewsCount,
    this.commentCount,
    this.likesCount,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
  });

  static SocialPostModel fromJson(dynamic json) {
    if (json is! Map) {
      return SocialPostModel(id: json?.toString());
    }

    List<MediaModel> mediaList = [];
    if (json['media_urls'] != null) {
      if (json['media_urls'] is List) {
        mediaList = (json['media_urls'] as List)
            .map((item) => MediaModel.fromJson(item))
            .toList();
      }
    }

    return SocialPostModel(
      id: json['id']?.toString(),
      brokerId: json['broker_id'] != null
          ? BrokerModel.fromJson(json['broker_id'])
          : null,
      propertyId: json['property_id']?.toString(),
      platform: json['platform'] != null
          ? SocialPlatform.fromDbValue(json['platform'])
          : null,
      pageId: json['page_id']?.toString(),
      postId: json['post_id']?.toString(),
      caption: json['caption']?.toString(),
      mediaUrls: mediaList,
      permalink: json['permalink']?.toString(),
      viewsCount: json['views_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      likesCount: json['likes_count'] as int? ?? 0,
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'].toString())?.toLocal()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())?.toLocal()
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())?.toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (id != null) data['id'] = id;
    data['broker_id'] = brokerId?.id;
    if (propertyId != null) data['property_id'] = propertyId;
    if (platform != null) data['platform'] = platform?.dbValue;
    if (pageId != null) data['page_id'] = pageId;
    if (postId != null) data['post_id'] = postId;
    data['caption'] = caption;
    if (mediaUrls != null) {
      data['media_urls'] = mediaUrls!.map((item) => item.toJson()).toList();
    }
    data['permalink'] = permalink;
    data['views_count'] = viewsCount;
    data['comment_count'] = commentCount;
    data['likes_count'] = likesCount;
    if (publishedAt != null) {
      data['published_at'] = publishedAt?.toUtc().toIso8601String();
    }
    if (createdAt != null) {
      data['created_at'] = createdAt?.toUtc().toIso8601String();
    }
    if (updatedAt != null) {
      data['updated_at'] = updatedAt?.toUtc().toIso8601String();
    }
    return data;
  }

  SocialPostModel copyWith({
    String? id,
    BrokerModel? brokerId,
    String? propertyId,
    SocialPlatform? platform,
    String? pageId,
    String? postId,
    String? caption,
    List<MediaModel>? mediaUrls,
    String? permalink,
    int? viewsCount,
    int? commentCount,
    int? likesCount,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SocialPostModel(
      id: id ?? this.id,
      brokerId: brokerId ?? this.brokerId,
      propertyId: propertyId ?? this.propertyId,
      platform: platform ?? this.platform,
      pageId: pageId ?? this.pageId,
      postId: postId ?? this.postId,
      caption: caption ?? this.caption,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      permalink: permalink ?? this.permalink,
      viewsCount: viewsCount ?? this.viewsCount,
      commentCount: commentCount ?? this.commentCount,
      likesCount: likesCount ?? this.likesCount,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        brokerId,
        propertyId,
        platform,
        pageId,
        postId,
        caption,
        mediaUrls,
        permalink,
        viewsCount,
        commentCount,
        likesCount,
        publishedAt,
        createdAt,
        updatedAt,
      ];
}
