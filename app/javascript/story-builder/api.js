import axios from 'axios';

const requestConfig = () => ({
  headers: {
    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
    'X-Requested-With': 'XMLHttpRequest'
  }
})

const normalizeTags = (tags) => tags.map((tag) => tag.id || tag.name);

export const updateContent = (storyId, story, storyLocale) => {
  const normalizedStory = {
    ...story,
    tag_ids: normalizeTags(story.tags)
  }

  if (storyId) {
    return axios.put(`/stories/${storyId}.json?story_builder=true&story_locale=${storyLocale}`, { story: normalizedStory }, requestConfig());
  } else {
    return axios.post(`/stories.json?story_builder=true&story_locale=${storyLocale}`, { story: normalizedStory }, requestConfig());
  }
}

export const uploadImage = (story, file, onProgress) => {
  const form = new FormData();
  form.append("Content-Type", file.type);
  form.append("image[picture]", file);
  form.append("image[imageable_type]", "Story");
  form.append("image[imageable_id]", story.id)

  const options = {
    ...requestConfig(),
    onUploadProgress: progressEvent => onProgress((progressEvent.loaded / progressEvent.total) * 100)
  };

  return axios.post(`/commoners/${story.commoner_id}/images`, form, options);
};

export const deleteImage = (commonerId, imageUrl) => {
  const imageId = imageUrl.match(new RegExp(`/images/(\\d+)`))[1];
  return axios.delete(`/commoners/${commonerId}/images/${imageId}`, requestConfig());
}

export const publishStory = (storyId, locale, options = {}) => {
  return axios.post(`/${locale}/stories/${storyId}/publish`, options, requestConfig());
}
